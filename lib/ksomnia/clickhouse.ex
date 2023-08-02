defmodule Ksomnia.Clickhouse do
  use Pillar,
    connection_strings: [
      "http://localhost:8123/database"
    ],
    name: __MODULE__,
    pool_size: 15
end
