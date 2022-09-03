defmodule Ksomnia.SourceMapper do
  use Tesla
  plug Tesla.Middleware.BaseUrl, "http://localhost:3000"
  plug Tesla.Middleware.JSON
  alias Ksomnia.SourceMap

  # TODO: handle when commit doesn't exists
  def map_stacktrace(error_identity) do
    with {:source_map, %SourceMap{} = source_map} <-
           {:source_map, get_source_map(error_identity)},
         %{body: body} <- do_map_stacktrace(error_identity.stacktrace, source_map) do
      body
    end
  end

  def do_map_stacktrace(stack, source_map) do
    post("/map_stacktrace", %{
      stack: stack,
      file_path: source_map_file_path(source_map)
    })
  end

  def get_source_map(error_identity) do
    SourceMap.latest_for_commit_hash(error_identity.commit_hash)
  end

  def source_map_file_path(source_map) do
    Path.expand(SourceMap.source_map_path(source_map))
  end
end
