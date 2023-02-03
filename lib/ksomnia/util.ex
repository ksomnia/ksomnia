defmodule Ksomnia.Util do
  def add_if(map, _key, nil), do: map

  def add_if(map, key, value) do
    Map.put(map, key, value)
  end

  def truncate_string(string, n) do
    if String.length(string) > n do
      String.slice(string, 0, n) <> "..."
    else
      string
    end
  end
end
