defmodule Ksomnia.Cassandra.Keyspace do
  use Cassandrax.Keyspace, cluster: Ksomnia.CassandraCluster, name: "user_keyspace"
end
