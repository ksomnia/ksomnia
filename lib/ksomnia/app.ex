defmodule Ksomnia.App do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.Team
  alias Ksomnia.Repo

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "apps" do
    field :name, :string
    field :token, :string
    belongs_to :team, Team, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_token()
  end

  def put_token(changeset) do
    if changeset.data.token do
      changeset
    else
      put_change(changeset, :token, Ksomnia.Security.random_string(16))
    end
  end

  def all() do
    Repo.all(App)
  end

  def update(app, attrs) do
    app
    |> changeset(attrs)
    |> Repo.update()
  end

  def create(team_id, attrs) when is_binary(team_id) do
    %App{team_id: team_id}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def for_team(team_id) do
    from(a in App,
      where: a.team_id == ^team_id,
      order_by: [asc: a.inserted_at]
    )
    |> Repo.all()
  end

  def for_user(user_id) do
    teams =
      from(t in Team,
        join: tu in assoc(t, :team_users),
        where: tu.user_id == ^user_id
      )
      |> Repo.all()

    grouped_teams =
      Enum.group_by(teams, & &1.id)

    grouped_apps =
      from(a in App, where: a.team_id in ^Enum.map(teams, & &1.id))
      |> Repo.all()
      |> Enum.group_by(& &1.team_id)

    grouped_teams
    |> Enum.map(fn {_, [team]} ->
      Map.put(team, :apps, grouped_apps[team.id])
    end)
  end
end
