defmodule Ksomnia.Repo do
  use Ecto.Repo,
    otp_app: :ksomnia,
    adapter: Ecto.Adapters.Postgres

  require Logger

  def init(_type, config) do
    database_url = System.get_env("KSOMNIA_DATABASE_URL")

    if database_url do
      Logger.debug("Using $KSOMNIA_DATABASE_URL to configure the database connection")
      {:ok, Keyword.put(config, :url, database_url)}
    else
      Logger.warn("$KSOMNIA_DATABASE_URL is not set")
      {:ok, config}
    end
  end

  def count(query) do
    aggregate(query, :count)
  end

  def last(query) do
    Ecto.Query.last(query) |> one()
  end

  def first(query) do
    Ecto.Query.first(query) |> one()
  end

  @doc """
  Process a query in chunks.

  ## Example

      query
      |> Repo.chunk(100)
      |> Stream.each(&process_batch)
      |> Stream.run()
  """
  def chunk(query, chunk_size) do
    chunk_stream =
      Stream.unfold(1, fn page_number ->
        page = Ksomnia.Pagination.paginate(query, page_number, chunk_size)

        {page.entries, page_number + 1}
      end)

    Stream.take_while(chunk_stream, fn
      [] -> false
      _ -> true
    end)
  end
end
