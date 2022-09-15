defmodule SampleApp.Deploy do
  use Tesla
  plug Tesla.Middleware.BaseUrl, "http://localhost:4000"
  plug Tesla.Middleware.JSON
  alias Tesla.Multipart

  def deploy(token, commit_hash) do
    multipart =
      Multipart.new()
      |> Multipart.add_field("app_token", token)
      |> Multipart.add_field("commit_hash", commit_hash)
      |> Multipart.add_file(asset_path("app.js.map"), name: "source_map")
      |> Multipart.add_file(asset_path("app.js"), name: "target_file")

    post("/api/v1/source_maps", multipart)
  end

  def asset_path(target) do
    Path.join([File.cwd!(), "priv", "static", "assets", target])
  end
end
