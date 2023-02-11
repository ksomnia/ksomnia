defmodule Ksomnia.Queries.AppQueries do
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.Team
  alias Ksomnia.Repo

  @spec search_by_name(Ecto.Query.t(), binary()) :: Ecto.Query.t()
  def search_by_name(query, ""), do: query

  def search_by_name(query, search_query) do
    from(a in query,
      where: ilike(a.name, ^"%#{search_query}%")
    )
  end

  @spec for_team(binary()) :: Ecto.Query.t()
  def for_team(team_id) do
    from(a in App,
      where: a.team_id == ^team_id,
      order_by: [asc: a.inserted_at]
    )
  end

  @spec for_user(binary()) :: [%Team{}]
  def for_user(user_id) do
    teams =
      from(t in Team,
        join: tu in assoc(t, :team_users),
        where: tu.user_id == ^user_id
      )
      |> Repo.all()

    grouped_teams = Enum.group_by(teams, & &1.id)

    grouped_apps =
      from(a in App, where: a.team_id in ^Enum.map(teams, & &1.id))
      |> Repo.all()
      |> Enum.group_by(& &1.team_id)

    grouped_teams
    |> Enum.map(fn {_, [team]} ->
      Map.put(team, :apps, grouped_apps[team.id] || [])
    end)
  end

  @spec get_by_id(binary()) :: App.t()
  def get_by_id(app_id) do
    Repo.get(App, app_id)
  end
end
