defmodule KsomniaWeb.ProjectController do
  use KsomniaWeb, :controller
  alias Ksomnia.Project
  alias Ksomnia.Repo
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

  def show(conn, %{"id" => project_id}) do
    project = Repo.get(Project, project_id)
    render(conn, "show.html", project: project)
  end

  def index(conn, _params) do
    user = conn.assigns.user
    projects = Project.for_user(user)

    render(conn, "index.html", projects: projects)
  end
end
