defmodule Ksomnia.Repo.Migrations.CreateProjectUsers do
  use Ecto.Migration

  def change do
    create table(:project_users) do
      add :project_id, references(:projects, type: :uuid)
      add :user_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
