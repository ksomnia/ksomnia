defmodule KsomniaWeb.ProjectController do
  use KsomniaWeb, :controller
  alias Ksomnia.Project
  action_fallback KsomniaWeb.FallbackController

  plug :put_root_layout, {KsomniaWeb.LayoutView, "app_root.html"}

  def create(conn, params) do
    user = conn.assigns.user

    with {:ok, %{project: project}} <- Project.create(user, params) do
      conn
      |> put_resp_header("location", Routes.project_path(conn, :show, project.id))
      |> json(%{status: "ok"})
    end
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def index(conn, _params) do
    user = conn.assigns.user
    projects = Project.for_user(user)

    render(conn, "index.html", projects: projects)
  end
end
