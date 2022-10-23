defmodule Ksomnia.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :team_id, references(:teams, type: :uuid)
      add :inviter_id, references(:users, type: :uuid)
      add :accepted_at, :naive_datetime, null: true

      timestamps()
    end

    create index(:invites, [:email])
    create index(:invites, [:team_id])
    create index(:invites, [:email, :team_id], unique: true)
  end
end
