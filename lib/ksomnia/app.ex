defmodule Ksomnia.App do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ecto.Multi

  @type t() :: %App{}
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "apps" do
    field :name, :string

    field :avatar_original_path, :string
    field :avatar_resized_paths, :map, default: %{}

    belongs_to :team, Team, type: Ecto.ShortUUID

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name, :avatar_original_path, :avatar_resized_paths])
    |> validate_required([:name])
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
end
