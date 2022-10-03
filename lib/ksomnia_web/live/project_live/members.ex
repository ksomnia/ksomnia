defmodule KsomniaWeb.ProjectLive.Members do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.Project
  alias Ksomnia.Repo
  alias Ksomnia.User

  on_mount {KsomniaWeb.Live.SidebarHighlight, [set_section: :members]}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :members, [])}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    project = Repo.get(Project, id)
    members = User.for_project(project)

    socket =
      socket
      |> assign(:project, project)
      |> assign(:members, members)

    {:noreply, socket}
  end
end
