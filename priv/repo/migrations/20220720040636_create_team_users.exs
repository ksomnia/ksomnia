defmodule Ksomnia.Repo.Migrations.CreateTeamUsers do
  use Ecto.Migration

  def change do
    create table(:team_users) do
      add :team_id, references(:teams, type: :uuid)
      add :user_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
