defmodule Ksomnia.App do
  use Ksomnia.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.Team

  @type t() :: %App{}

  schema "apps" do
    field :name, :string

    field :avatar_original_path, :string
    field :avatar_resized_paths, :map, default: %{}

    belongs_to :team, Team

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
end
