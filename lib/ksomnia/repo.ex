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
end
