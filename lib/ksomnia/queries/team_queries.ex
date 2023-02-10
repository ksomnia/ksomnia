defmodule Ksomnia.Queries.TeamQueries do
  import Ecto.Query
  alias Ksomnia.Team
  use Ksomnia.DataHelper, [:get, Team]

  @spec for_user(Team.t()) :: [Team.t()]
  def for_user(user) do
    from(t in Team,
      join: tu in assoc(t, :team_users),
      where: tu.user_id == ^user.id,
      order_by: [asc: t.inserted_at]
    )
    |> Repo.all()
  end
end