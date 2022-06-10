defmodule Ksomnia.Repo do
  use Ecto.Repo,
    otp_app: :ksomnia,
    adapter: Ecto.Adapters.Postgres

  require Logger

  def init(_type, config) do
    database_url = System.get_env("DATABASE_URL")

    if database_url do
      Logger.debug "Using $DATABASE_URL to configure the database connection"
      {:ok, Keyword.put(config, :url, database_url)}
    else
      Logger.warn "$DATABASE_URL is not set"
      {:ok, config}
    end
  end
end
