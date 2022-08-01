defmodule Ksomnia.Repo.Migrations.CreateErrorIdentities do
  use Ecto.Migration

  def change do
    create table(:error_identities, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :source, :text
      add :message, :text
      add :stacktrace, :text
      add :line_number, :string
      add :column_number, :string
      add :track_count, :bigint, default: 1
      add :last_error_at, :naive_datetime
      add :app_id, references(:apps, type: :uuid)

      timestamps()
    end

    create index(
             "error_identities",
             [
               :source,
               :line_number,
               :column_number,
               :message,
               :stacktrace
             ],
             unique: true
           )
  end
end
