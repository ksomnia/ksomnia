defmodule Ksomnia.Repo.Migrations.CreateErrorRecords do
  use Ecto.Migration

  def change do
    create table(:error_records, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :ip_address, :string
      add :user_agent, :text
      add :client_version, :text

      add :app_id, references(:apps, type: :uuid)
      add :error_identity_id, references(:error_identities, type: :uuid)

      timestamps()
    end
  end
end
