defmodule Ksomnia.Invite do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.Invite
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.User
  alias Ksomnia.Queries.UserQueries
  alias Ksomnia.Queries.InviteQueries
  alias Ksomnia.Repo

  @type t() :: %Invite{}
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

    if UserQueries.is_member?(email, team_id) do
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

  def revoke(invite) do
    Repo.delete(invite)
  end

  def reject(invite_id, invitee) do
    with %Invite{} = invite <- InviteQueries.get_by_id(invite_id),
         true <- invite.email == invitee.email do
      Repo.delete(invite)
    else
      _ -> :error
    end
  end

  def accept(invite_id, invitee) when is_binary(invite_id) do
    with %Invite{} = invite <- InviteQueries.get_by_id(invite_id),
         {:ok, _} = result <- accept(invite, invitee) do
      result
    else
      _ -> :error
    end
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

  def delete_if_exists(email, team_id) do
    with %Invite{} = invite <- InviteQueries.get_by_email_and_team_id(email, team_id) do
      Repo.delete(invite)
    end
  end
end
