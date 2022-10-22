defmodule Ksomnia.Invite do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Ksomnia.Invite
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.User
  alias Ksomnia.Repo

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "invites" do
    field :email, :string
    field :accepted_at, :naive_datetime
    belongs_to :team, Team, type: Ksomnia.ShortUUID6
    belongs_to :inviter, User, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end

  def new(team_id, attrs) do
    %Invite{team_id: team_id}
    |> changeset(attrs)
  end

  def create(team_id, attrs) do
    new(team_id, attrs)
    |> Repo.insert()
  end

  def for_team(team) do
    team = Repo.preload(team, :invites)
    team.invites
  end

  def for_user_email(email) do
    from(i in Invite, where: i.email == ^email, preload: [:team])
    |> Repo.all()
  end

  def revoke(invite) do
    Repo.delete(invite)
  end

  def accept(invite, invitee) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:invite, change(invite, accepted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)))
    |> Ecto.Multi.insert(:team_user, fn %{} ->
      TeamUser.new(invite.team_id, invitee.id, %{role: "member"})
    end)
    |> Repo.transaction()
  end
end
