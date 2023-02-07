defmodule Ksomnia.Repo.Migrations.CreateUserKeyspace do
  use Ecto.Migration

  def up do
    # TODO:
    :timer.sleep(:timer.seconds(1))

    {:ok, _} =
      Cassandrax.cql(Ksomnia.CassandraCluster, """
        CREATE KEYSPACE IF NOT EXISTS user_keyspace
          WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1}
      """)
      |> IO.inspect()

    {:ok, _} =
      Cassandrax.cql(Ksomnia.CassandraCluster, """
        CREATE TABLE IF NOT EXISTS user_keyspace.user_by_id(
          id uuid,
          username varchar,
          email varchar,
          PRIMARY KEY (id)
        );
      """)
      |> IO.inspect()
  end

  def down do
    # TODO:
    :timer.sleep(:timer.seconds(1))

    Cassandrax.cql(Ksomnia.CassandraCluster, "DROP KEYSPACE user_keyspace") |> IO.inspect()
    Cassandrax.cql(Ksomnia.CassandraCluster, "DROP TABLE user_keyspace.user_by_id") |> IO.inspect()
  end
end
