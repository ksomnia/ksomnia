defmodule Mix.Tasks.MigrateClickhouse do
  use Mix.Task

  def run(_args) do
    connection_string = Application.get_env(:ksomnia, :clickhouse_url)
    conn = Pillar.Connection.new(connection_string)
    Pillar.Migrations.migrate(conn)
  end
end
