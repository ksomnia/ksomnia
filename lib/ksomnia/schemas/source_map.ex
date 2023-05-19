defmodule Ksomnia.SourceMap do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.SourceMap

  @type t() :: %SourceMap{}

  @primary_key {:id, Uniq.UUID, version: 4, autogenerate: true}
  schema "source_maps" do
    field :commit_hash, :string
    field :source_map_file_hash, :string
    field :target_file_hash, :string
    field :source_map, :map, virtual: true
    field :target_file, :map, virtual: true
    belongs_to :app, App, type: Uniq.UUID

    timestamps()
  end

  @doc false
  def changeset(source_map, attrs) do
    source_map
    |> cast(attrs, [:commit_hash, :source_map, :target_file])
    |> validate_required([:commit_hash, :source_map, :target_file])
    |> source_map_hash()
    |> put_target_file_hash()
    |> unique_constraint([:target_file_hash, :source_map_file_hash])
  end

  def source_map_hash(changeset) do
    source_map = changeset.changes.source_map
    hash = file_hashsum(File.read!(source_map.path))
    put_change(changeset, :source_map_file_hash, hash)
  end

  def put_target_file_hash(changeset) do
    target_file = changeset.changes.target_file
    hash = file_hashsum(File.read!(target_file.path))
    put_change(changeset, :target_file_hash, hash)
  end

  def file_hashsum(content) do
    Base.encode16(:erlang.md5(content), case: :lower)
  end

  @default_source_map_path "tmp/source_maps"

  def source_map_path(source_map) do
    Path.join([
      @default_source_map_path,
      source_map.id,
      source_map.source_map_file_hash
    ])
  end
end
