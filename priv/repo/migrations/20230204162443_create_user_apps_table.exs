defmodule Ksomnia.Repo.Migrations.CreateUserAppsTable do
  use Ecto.Migration

  def change do
    create table(:user_apps, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, type: :uuid)
      add :app_id, references(:apps, type: :uuid)

      timestamps()
    end

    create index(:user_apps, [:user_id, :app_id], unique: true)
  end
end
