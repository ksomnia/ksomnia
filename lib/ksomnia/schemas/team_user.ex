defmodule Ksomnia.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.TeamUser
  alias Ksomnia.Team
  alias Ksomnia.User

  @type t() :: %TeamUser{}

  schema "team_users" do
    belongs_to(:team, Team, type: Uniq.UUID)
    belongs_to(:user, User, type: Uniq.UUID)
    field(:role, :string)
    field(:completed_onboarding_at, :naive_datetime)

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

  def complete_onboarding(team_user) do
    completed_onboarding_at = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    team_user
    |> change(completed_onboarding_at: completed_onboarding_at)
  end
end
