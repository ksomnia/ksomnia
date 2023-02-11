defmodule Ksomnia.Queries.TeamUserQueries do
  import Ecto.Query
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.Team
  alias Ksomnia.TeamUser

  @spec is_owner(Team.t(), User.t()) :: boolean()
  def is_owner(%Team{} = team, %User{} = user) do
    with %TeamUser{} = team_user <- get_by_team_id_and_user_id(team.id, user.id) do
      team_user.role == "owner"
    else
      _ -> false
    end
  end

  @spec team_has_single_owner(Team.t()) :: boolean()
  def team_has_single_owner(%Team{} = team) do
    Repo.one(
      from(tu in TeamUser,
        where: tu.team_id == ^team.id and tu.role == ^"owner",
        select: count(tu.id)
      )
    ) == 1
  end

  @spec completed_onboarding?(Team.t(), User.t()) :: boolean()
  def completed_onboarding?(team, target_user) do
    with %TeamUser{} = team_user <- get_by_team_id_and_user_id(team.id, target_user.id) do
      team_user.completed_onboarding_at != nil
    end
  end

  @spec get_by_team_id_and_user_id(binary(), binary()) :: TeamUser.t() | nil
  def get_by_team_id_and_user_id(team_id, user_id) do
    Repo.get_by(TeamUser, team_id: team_id, user_id: user_id)
  end
end
