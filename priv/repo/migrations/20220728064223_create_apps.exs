defmodule Ksomnia.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:apps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :team_id, references(:teams, type: :uuid)

      timestamps()
    end
  end
end
