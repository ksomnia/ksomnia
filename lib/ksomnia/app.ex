defmodule Ksomnia.App do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ecto.Multi

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "apps" do
    field :name, :string
    belongs_to :team, Team, type: Ecto.ShortUUID

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def all() do
    Repo.all(App)
  end

  def new(team_id, attrs) do
    %App{team_id: team_id}
    |> changeset(attrs)
  end

  def update(app, attrs) do
    app
    |> changeset(attrs)
    |> Repo.update()
  end

  def create(team_id, user_id, attrs) do
    Multi.new()
    |> Multi.insert(:app, new(team_id, attrs))
    |> Multi.run(:app_token, fn _repo, %{app: app} ->
      AppToken.create(app.id, user_id)
    end)
    |> Repo.transaction()
  end

  def for_team(team_id) do
    from(a in App,
      where: a.team_id == ^team_id,
      order_by: [asc: a.inserted_at]
    )
  end

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

  def search_by_name(query, ""), do: query

  def search_by_name(query, search_query) do
    from(a in query,
      where: ilike(a.name, ^"%#{search_query}%")
    )
  end
end
