defmodule Ksomnia.Util do
  def add_if(map, key, nil), do: map

  def add_if(map, key, value) do
    Map.put(map, key, value)
  end
end
