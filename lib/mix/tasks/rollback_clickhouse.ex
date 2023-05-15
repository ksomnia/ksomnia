defmodule Mix.Tasks.RollbackClickhouse do
  use Mix.Task

  def run(_args) do
    connection_string = Application.get_env(:ksomnia, :clickhouse_url)
    conn = Pillar.Connection.new(connection_string)
    Pillar.Migrations.rollback(conn)
  end
end
