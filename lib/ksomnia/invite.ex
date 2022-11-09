defmodule Ksomnia.Invite do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Ksomnia.Invite
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.User
  alias Ksomnia.Repo
  use Ksomnia.DataHelper, [:get, Invite]

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "invites" do
    field :email, :string
    field :accepted_at, :naive_datetime
    belongs_to :team, Team, type: Ecto.ShortUUID
    belongs_to :inviter, User, type: Ecto.ShortUUID

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint([:email, :team_id], message: "has already been invited")
  end

  def new(team_id, attrs) do
    %Invite{team_id: team_id}
    |> changeset(attrs)
    |> ensure_not_member
  end

  def ensure_not_member(%{changes: %{email: email}} = changeset) do
    team_id = changeset.data.team_id

    if TeamUser.is_member(team_id, email) do
      changeset
      |> add_error(:email, "the user is already a team member")
    else
      changeset
    end
  end

  def ensure_not_member(changeset), do: changeset

  def create(team_id, attrs) do
    with {:ok, invite} <- Repo.insert(new(team_id, attrs)),
         %Swoosh.Email{} = email <- Ksomnia.UserInviteEmail.pending_invite_notification(invite) do
      Ksomnia.Mailer.deliver(email)
      {:ok, invite}
    end
  end

  def pending_for_team(team) do
    from(i in Invite, where: i.team_id == ^team.id and is_nil(i.accepted_at))
    |> Repo.all()
  end

  def for_user_email(email) do
    from(i in Invite, where: i.email == ^email and is_nil(i.accepted_at), preload: [:team])
    |> Repo.all()
  end

  def revoke(invite) do
    Repo.delete(invite)
  end

  def reject(invite_id, invitee) do
    if invite = Repo.get_by(Invite, email: invitee.email, id: invite_id) do
      Repo.delete(invite)
    else
      :error
    end
  end

  def accept(invite_id, invitee) when is_binary(invite_id) do
    invite = Repo.get(Invite, invite_id)
    accept(invite, invitee)
  end

  def accept(invite, invitee) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :invite,
      change(invite, accepted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))
    )
    |> Ecto.Multi.insert(:team_user, fn %{} ->
      TeamUser.new(invite.team_id, invitee.id, %{role: "member"})
    end)
    |> Repo.transaction()
  end

  def delete_if_exists(fields) do
    with %Invite{} = invite <- get(fields) do
      Repo.delete(invite)
    end
  end
end
