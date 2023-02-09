defmodule Ksomnia.Queries.TeamUserQueries do
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  import Ecto.Query
  use Ksomnia.DataHelper, [:get, TeamUser]

  @spec is_owner(Team.t(), User.t()) :: boolean()
  def is_owner(%Team{} = team, %User{} = user) do
    with %TeamUser{} = team_user <- get(team_id: team.id, user_id: user.id) do
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
    with %TeamUser{} = team_user <- get(team_id: team.id, user_id: target_user.id) do
      team_user.completed_onboarding_at != nil
    end
  end
end
