defmodule KsomniaWeb.ProjectLive.Show do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.App
  alias Ksomnia.Project
  alias Ksomnia.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :apps, [])}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    project = Repo.get(Project, id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:project, project)
      |> assign(:apps, App.for_project(project.id))
      |> assign(:app, nil)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Show Project with Apps")
    |> assign(:app, nil)
  end

  defp apply_action(socket, :new_app, _params) do
    socket
    |> assign(:page_title, "New App")
    |> assign(:app, %App{project_id: socket.assigns.project.id})
  end

  defp page_title(:new_app), do: "New App"
  defp page_title(:show), do: "Show App"
  defp page_title(:edit), do: "Edit App"
end
