defmodule Ksomnia.Queries.UserQueries do
  import Ecto.Query
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.Team
  alias Ksomnia.Queries.TeamUserQueries

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

  @spec is_member?(binary(), binary()) :: boolean()
  def is_member?(user_email, team_id) do
    with %User{} = user <- get_by_email(user_email) do
      !!TeamUserQueries.get_by_team_id_and_user_id(team_id, user.id)
    else
      _ -> false
    end
  end

  @spec get_by_email(binary()) :: User.t() | nil
  def get_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @spec get_by_id(binary()) :: User.t() | nil
  def get_by_id(id) do
    Repo.get(User, id)
  end
end
