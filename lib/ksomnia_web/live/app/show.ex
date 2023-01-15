defmodule KsomniaWeb.AppLive.Show do
  use KsomniaWeb, :live_view

  alias Ksomnia.Pagination
  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.SourceMap

  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :show]}

  @page_size 10
  @surround_size 2

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:display_token, nil)
      |> assign(:team, %{})

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    app = Repo.get(App, id)
    team = Repo.preload(app, :team).team
    current_page = Map.get(params, "page", "1") |> String.to_integer()

    paginated =
      app
      |> ErrorIdentity.for_app()
      |> Pagination.paginate(current_page, @page_size)

    error_identities = paginated.entries

    latest_source_map = SourceMap.latest_for_app(app)

    pagination = %{
      page_size: @page_size,
      surround_size: @surround_size,
      current_page: current_page,
      total_pages: paginated.total_pages,
      entry_count: paginated.entry_count
    }

    socket =
      socket
      |> assign(:page_title, "#{app.name} · #{team.name}")
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:error_identities, error_identities)
      |> assign(:pagination, pagination)
      |> assign(:latest_source_map, latest_source_map)
      |> assign(:__current_app__, app.id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_token_visibility", _value, socket) do
    display_token = if socket.assigns.display_token, do: nil, else: socket.assigns.app.token
    {:noreply, assign(socket, :display_token, display_token)}
  end
end
