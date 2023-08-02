defmodule Ksomnia.Repo.Migrations.CreateTeamUsers do
  use Ecto.Migration

  def change do
    create table(:team_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :team_id, references(:teams, type: :uuid)
      add :user_id, references(:users, type: :uuid)
      add :role, :string
      add :completed_onboarding_at, :naive_datetime

      timestamps()
    end

    create index(:team_users, [:user_id, :team_id], unique: true)
  end
end
