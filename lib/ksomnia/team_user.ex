defmodule Ksomnia.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.TeamUser
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Repo
  alias Ksomnia.Invite
  use Ksomnia.DataHelper, [:get, TeamUser]

  schema "team_users" do
    belongs_to :team, Team, type: Ksomnia.ShortUUID6
    belongs_to :user, User, type: Ksomnia.ShortUUID6
    field :role, :string

    timestamps()
  end

  @user_roles ["owner", "member"]

  @doc false
  def changeset(team_user, attrs) do
    team_user
    |> cast(attrs, [:user_id, :team_id, :role])
    |> validate_required([:user_id, :team_id])
    |> validate_inclusion(:role, @user_roles)
  end

  def new(team_id, user_id, attrs) do
    %TeamUser{team_id: team_id, user_id: user_id}
    |> changeset(attrs)
  end

  def is_member(team_id, email) when not is_nil(team_id) and not is_nil(email) do
    with %User{} = user <- User.get(email: email) do
      Repo.get_by(TeamUser, team_id: team_id, user_id: user.id)
    end
  end

  def is_owner(%Team{} = team, %User{} = user) do
    with %TeamUser{} = team_user <- TeamUser.get(team_id: team.id, user_id: user.id) do
      team_user.role == "owner"
    else
      _ -> false
    end
  end

  def is_single_owner(%Team{} = team) do
    Repo.one(
      from(tu in TeamUser,
        where: tu.team_id == ^team.id and tu.role == ^"owner",
        select: count(tu.id)
      )
    ) == 1
  end

  def remove_user(%Team{} = team, %User{} = target_user) do
    with %TeamUser{} = team_user <- TeamUser.get(team_id: team.id, user_id: target_user.id) do
      Invite.delete_if_exists(email: target_user.email, team_id: team.id)
      Repo.delete(team_user)
    end
  end
end
