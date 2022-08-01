defmodule KsomniaWeb.ProjectLive.Index do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.Project
  alias Ksomnia.Repo

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = Repo.get(Ksomnia.User, user_id)

    session =
      socket
      |> assign(:current_user, user)
      |> assign(:apps, Project.for_user(user))

    {:ok, session}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Repo.get(Project, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Apps")
    |> assign(:project, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Repo.get(Project, id)
    {:ok, _} = Repo.delete(project)

    {:noreply, assign(socket, :apps, Project.all())}
  end
end
