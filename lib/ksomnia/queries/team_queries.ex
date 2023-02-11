defmodule Ksomnia.Queries.TeamQueries do
  import Ecto.Query
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Repo

  @spec for_user(User.t()) :: [Team.t()]
  def for_user(user) do
    from(t in Team,
      join: tu in assoc(t, :team_users),
      where: tu.user_id == ^user.id,
      order_by: [asc: t.inserted_at]
    )
    |> Repo.all()
  end

  @spec get_by_id(binary()) :: Team.t() | nil
  def get_by_id(team_id) do
    Repo.get(Team, team_id)
  end
end
