defmodule Ksomnia.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.TeamUser
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Repo

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
end
