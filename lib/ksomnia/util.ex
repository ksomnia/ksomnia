defmodule Ksomnia.Util do
  use Phoenix.Component

  def assign_if(socket, true, key, value) do
    socket |> assign(key, value)
  end

  def assign_if(socket, false, _key, _value) do
    socket
  end

  def add_if(map, _key, nil), do: map

  def add_if(map, _key, ""), do: map

  def add_if(map, key, value) do
    Map.put(map, key, value)
  end

  def toggle_value(map, key) do
    case Map.get(map, key) do
      nil -> Map.put(map, key, true)
      true -> Map.put(map, key, false)
      false -> Map.put(map, key, true)
    end
  end

  def truncate_string(string, n) do
    if String.length(string) > n do
      String.slice(string, 0, n) <> "..."
    else
      string
    end
  end

  def utc_now() do
    NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
  end
end
