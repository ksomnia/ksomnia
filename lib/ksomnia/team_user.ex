defmodule Ksomnia.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.TeamUser
  alias Ksomnia.Team
  alias Ksomnia.User

  schema "team_users" do
    belongs_to :team, Team, type: Ksomnia.ShortUUID6
    belongs_to :user, User, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(team_user, attrs) do
    team_user
    |> cast(attrs, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
  end

  def new(team_id, user_id) do
    %TeamUser{team_id: team_id, user_id: user_id}
  end
end
