defmodule SampleAppWeb.PageController do
  use SampleAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def deploy(conn, %{"token" => token, "commit_hash" => commit_hash}) do
    with {:ok, _} <- SampleApp.Deploy.deploy(token, commit_hash) do
      json(conn, %{"status" => "ok"})
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found"})
    end
  end
end
