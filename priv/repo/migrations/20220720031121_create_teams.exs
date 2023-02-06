defmodule Ksomnia.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :avatar_original_path, :string
      add :avatar_resized_paths, :map, default: %{}

      timestamps()
    end
  end
end
