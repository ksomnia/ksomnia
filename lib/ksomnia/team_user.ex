defmodule Ksomnia.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.TeamUser
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Repo
  alias Ksomnia.Invite
  alias Ksomnia.Queries.TeamUserQueries

  @type t() :: %TeamUser{}

  schema "team_users" do
    belongs_to :team, Team, type: Ecto.ShortUUID
    belongs_to :user, User, type: Ecto.ShortUUID
    field :role, :string
    field :completed_onboarding_at, :naive_datetime

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

  def remove_user(%Team{} = team, %User{} = target_user) do
    with %TeamUser{} = team_user <-
           TeamUserQueries.get_by_team_id_and_user_id(team.id, target_user.id),
         _ <- Invite.delete_if_exists(target_user.email, team.id),
         {:ok, _} <- Repo.delete(team_user) do
      {:ok, team_user}
    end
  end

  def complete_onboarding(team, target_user) do
    with %TeamUser{} = team_user <-
           TeamUserQueries.get_by_team_id_and_user_id(team.id, target_user.id),
         {:ok, _} <- do_complete_onboarding(team_user) do
      :ok
    end
  end

  defp do_complete_onboarding(team_user) do
    team_user
    |> change(completed_onboarding_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))
    |> Repo.update()
  end
end
