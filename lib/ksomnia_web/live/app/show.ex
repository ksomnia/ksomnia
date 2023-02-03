defmodule KsomniaWeb.AppLive.Show do
  use KsomniaWeb, :live_view

  alias Ksomnia.Pagination
  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.SourceMap
  alias KsomniaWeb.SearchQuery

  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :show]}

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
    search_query = Map.get(params, "query")

    pagination =
      app
      |> ErrorIdentity.for_app()
      |> Pagination.paginate(current_page)

    latest_source_map = SourceMap.latest_for_app(app)

    socket =
      socket
      |> assign(:search_query, KsomniaWeb.SearchQuery.new(search_query))
      |> assign(:page_title, "#{app.name} · #{team.name}")
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:pagination, pagination)
      |> assign(:latest_source_map, latest_source_map)
      |> assign(:__current_app__, app.id)

    {:noreply, socket}
  end

  def handle_event("perform_search_query", params, socket) do
    app = socket.assigns.app
    current_page = Map.get(params, "page", "1") |> String.to_integer()
    search_query = Map.get(params, "search_query_form_query", "")
    search_query_changeset = SearchQuery.new(search_query)

    {:noreply,
     socket
     |> assign(:search_query, search_query_changeset)
     |> do_search(app, search_query, current_page)}
  end

  @impl true
  def handle_event("toggle_token_visibility", _value, socket) do
    display_token = if socket.assigns.display_token, do: nil, else: socket.assigns.app.token
    {:noreply, assign(socket, :display_token, display_token)}
  end

  def do_search(socket, app, search_query, current_page) do
    search_query = String.trim(search_query)
    index = "error_identities-app_id-#{app.id}"

    with true <- search_query != "",
         {:ok, %{"hits" => hits}} <- Meilisearch.Search.search(index, search_query) do
      error_identities = ErrorIdentity.get_by_ids(Enum.map(hits, & &1["id"]))
      pagination = Pagination.paginate(error_identities, current_page)

      socket
      |> assign(:pagination, pagination)
    else
      _ ->
        pagination =
          app
          |> ErrorIdentity.for_app()
          |> Pagination.paginate(current_page)

        socket
        |> assign(:pagination, pagination)
    end
  end
end
