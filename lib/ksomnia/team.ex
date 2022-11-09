defmodule Ksomnia.Team do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.Repo
  alias Ksomnia.Invite
  alias Ecto.Multi
  use Ksomnia.DataHelper, [:get, Team]

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "teams" do
    field :name, :string
    has_many :team_users, TeamUser
    has_many :invites, Invite
    timestamps()
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2)
  end

  def new(attrs) do
    %Team{}
    |> changeset(attrs)
  end

  def create(user, attrs) do
    Multi.new()
    |> Multi.insert(:team, new(attrs))
    |> Ecto.Multi.insert(:team_user, fn %{team: team} ->
      TeamUser.new(team.id, user.id, %{role: "owner"})
    end)
    |> Repo.transaction()
  end

  def update(team, attrs) do
    team
    |> changeset(attrs)
    |> Repo.update()
  end

  def for_user(user) do
    from(p in Team,
      join: pu in assoc(p, :team_users),
      where: pu.user_id == ^user.id,
      order_by: [asc: p.inserted_at]
    )
    |> Repo.all()
  end

  def all() do
    Repo.all(Team)
  end
end
