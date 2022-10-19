defmodule Ksomnia.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :email, :string, null: false
      add :team_id, references(:teams, type: :uuid)
      add :inviter_id, references(:users, type: :uuid)
      add :accepted_at, :naive_datetime, null: true

      timestamps()
    end

    create index(:invites, [:email])
  end
end
