defmodule Ksomnia.Mutations.ErrorEventMutations do
  alias Ksomnia.ErrorEvent
  alias Ksomnia.Clickhouse
  alias Ksomnia.Util

  def create(app, error_identity, params) do
    error_event = ErrorEvent.new(app, error_identity, params)
    error_event = Util.ecto_struct_to_map(error_event)
    map = Map.drop(error_event, [:__meta__, :__struct__])
    keys = Map.keys(map)
    values = Enum.join(keys, ", ")
    select = Enum.map(keys, &"{#{&1}}") |> Enum.join(", ")

    Clickhouse.async_insert("INSERT INTO events (#{values}) SELECT #{select}", map)
  end
end
