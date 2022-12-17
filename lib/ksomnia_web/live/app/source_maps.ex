defmodule KsomniaWeb.AppLive.SourceMaps do
  use KsomniaWeb, :live_view

  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.SourceMap

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}
  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :source_maps]}

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
    team = Repo.get(Ksomnia.Team, app.team_id)
    source_maps = SourceMap.for_app(app)

    socket =
      socket
      |> assign(:page_title, "#{app.name} · Source maps")
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:source_maps, source_maps)
      |> assign(:__current_app__, app.id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_token_visibility", _value, socket) do
    display_token = if socket.assigns.display_token, do: nil, else: socket.assigns.app.token
    {:noreply, assign(socket, :display_token, display_token)}
  end
end
