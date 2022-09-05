defmodule KsomniaWeb.SourceMapController do
  use KsomniaWeb, :controller
  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.SourceMap
  require Logger

  def create(conn, %{"app_token" => token} = params) do
    with {:app, app} <- {:app, Repo.get_by(App, token: token)},
         {:ok, source_map_record} <- SourceMap.create(app, params),
         {:saved, :ok} <- {:saved, save_source_map(source_map_record, params["source_map"].path)} do
      json(conn, %{status: "ok"})
    else
      error ->
        Logger.error("#{__MODULE__} #{inspect(error)}")

        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found"})
    end
  end

  def save_source_map(source_map_record, file_path) do
    dest = SourceMap.source_map_path(source_map_record)
    dirname = Path.dirname(dest)

    Logger.info("#{__MODULE__}.save_source_map #{dest} #{dirname}")

    with {:mkdir_p, :ok} <- {:mkdir_p, File.mkdir_p(dirname)},
         {:copy, {:ok, _}} <- {:copy, File.copy(file_path, dest)} do
      :ok
    end
  end
end
