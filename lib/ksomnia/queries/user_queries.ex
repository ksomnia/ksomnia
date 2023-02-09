defmodule Ksomnia.Queries.UserQueries do
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  import Ecto.Query
  use Ksomnia.DataHelper, [:get, User]

  @spec for_team(Team.t()) :: Ecto.Query.t()
  def for_team(%Team{} = team) do
    from(u in User,
      join: tu in assoc(u, :team_users),
      where: tu.team_id == ^team.id,
      select: %{
        u
        | role: tu.role
      }
    )
  end

  @spec search_by_username(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  def search_by_username(query, ""), do: query

  def search_by_username(query, search_query) do
    from(u in query,
      where: ilike(u.email, ^"%#{search_query}%")
    )
  end

  @spec is_member?(binary(), Team.t()) :: boolean()
  def is_member?(user_email, %Team{} = team) do
    with %User{} = user <- get(email: user_email) do
      !!Repo.get_by(TeamUser, team_id: team.id, user_id: user.id)
    else
      _ -> false
    end
  end
end
