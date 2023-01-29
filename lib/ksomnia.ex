defmodule Ksomnia do
  @moduledoc """
  Ksomnia keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @pwd "SecretPassword"

  def sonic_push() do
    {:ok, conn} = Sonix.init({127, 0, 0, 1}, 1492)
    {:ok, conn} = Sonix.start(conn, "ingest", @pwd)

    Sonix.Modes.Ingest.push(conn, "messages", "obj:124", ~s(Uncaught TypeError: Cannot read properties of undefined (reading missing-key))
    |> IO.inspect()

    Sonix.quit(conn)
  end

  def sonic_search(word \\ "spiderman") do
    {:ok, conn} = Sonix.init({127, 0, 0, 1}, 1492)
    {:ok, conn} = Sonix.start(conn, "search", @pwd)

    IO.inspect(Sonix.query(conn, "messages", word))

    Sonix.quit(conn)
  end

  def sonic_suggest(word) do
    {:ok, conn} = Sonix.init({127, 0, 0, 1}, 1492)
    {:ok, conn} = Sonix.start(conn, "search", @pwd)

    IO.inspect(Sonix.suggest(conn, "messages", word))

    Sonix.quit(conn)
  end
end
