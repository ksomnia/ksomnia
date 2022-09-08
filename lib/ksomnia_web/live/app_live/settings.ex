defmodule KsomniaWeb.AppLive.Settings do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.SourceMap

  on_mount {KsomniaWeb.Live.SidebarHighlight, [set_section: :projects]}
  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :settings]}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:display_token, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    app = Repo.get(App, id)
    project = Repo.preload(app, :project).project
    error_identities = ErrorIdentity.for_app(app)
    latest_source_map = SourceMap.latest_for_app(app)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:app, app)
      |> assign(:project, project)
      |> assign(:error_identities, error_identities)
      |> assign(:latest_source_map, latest_source_map)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_token_visibility", _value, socket) do
    display_token = if socket.assigns.display_token, do: nil, else: socket.assigns.app.token
    {:noreply, assign(socket, :display_token, display_token)}
  end

  defp page_title(:show), do: "Show App"
  defp page_title(:edit), do: "Edit App"
  defp page_title(:settings), do: "Settings"
end