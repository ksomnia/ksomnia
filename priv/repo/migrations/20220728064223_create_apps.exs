defmodule Ksomnia.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:apps, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :token, :string
      add :project_id, references(:projects, type: :uuid)

      timestamps()
    end

    create index(:apps, [:token], unique: true)
  end
end
