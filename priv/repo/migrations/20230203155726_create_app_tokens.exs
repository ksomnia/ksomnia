defmodule Ksomnia.Repo.Migrations.CreateAppTokens do
  use Ecto.Migration

  def change do
    create table(:app_tokens) do
      add :token, :string, null: false
      add :revoked_at, :naive_datetime
      add :app_id, references(:apps, type: :uuid)
      add :user_id, references(:users, type: :uuid)

      timestamps()
    end

    create index(:app_tokens, [:token], unique: true)
  end
end
