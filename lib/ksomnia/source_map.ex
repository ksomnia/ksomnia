defmodule Ksomnia.SourceMap do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.SourceMap
  alias Ksomnia.Repo

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "source_maps" do
    field :commit_hash, :string
    field :source_map_file_hash, :string
    field :target_file_hash, :string
    field :source_map, :map, virtual: true
    field :target_file, :map, virtual: true
    belongs_to :app, App, type: Ksomnia.ShortUUID6

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

  def create(app, params) do
    %SourceMap{app_id: app.id}
    |> changeset(params)
    |> Repo.insert()
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

  def latest_for_commit_hash(commit_hash) do
    from(s in SourceMap,
      where: s.commit_hash == ^commit_hash,
      order_by: [desc: :inserted_at],
      limit: 1
    )
    |> Repo.one()
  end
end
