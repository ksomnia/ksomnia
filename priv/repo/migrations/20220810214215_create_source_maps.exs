defmodule Ksomnia.Repo.Migrations.CreateSourceMaps do
  use Ecto.Migration

  def change do
    create table(:source_maps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :commit_hash, :string
      add :source_map_file_hash, :string
      add :target_file_hash, :string
      add :app_id, references(:apps, type: :uuid)

      timestamps()
    end

    create index("source_maps", [:target_file_hash, :source_map_file_hash], unique: true)
  end
end
