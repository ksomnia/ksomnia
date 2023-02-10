defmodule Ksomnia.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.Repo
  alias Ksomnia.App
  alias Ksomnia.Invite
  alias Ecto.Multi

  @type t() :: %Team{}
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "teams" do
    field :name, :string
    field :avatar_original_path, :string
    field :avatar_resized_paths, :map, default: %{}

    has_many :team_users, TeamUser
    has_many :invites, Invite
    has_many :apps, App
    timestamps()
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :avatar_original_path, :avatar_resized_paths])
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
    |> Multi.insert(:team_user, fn %{team: team} ->
      TeamUser.new(team.id, user.id, %{role: "owner"})
    end)
    |> Repo.transaction()
  end

  def update(team, attrs) do
    team
    |> changeset(attrs)
    |> Repo.update()
  end
end
