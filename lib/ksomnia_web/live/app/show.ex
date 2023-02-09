defmodule KsomniaWeb.AppLive.Show do
  use KsomniaWeb, :live_view
  alias Ksomnia.Pagination
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.SourceMap
  alias KsomniaWeb.SearchQuery
  alias KsomniaWeb.LiveResource
  alias Ksomnia.Queries.TeamUserQueries

  on_mount({KsomniaWeb.AppLive.NavComponent, [set_section: :show]})

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:display_token, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    %{current_team: current_team, current_app: current_app, current_user: current_user} =
      LiveResource.get_assigns(socket)

    current_page = Map.get(params, "page", "1") |> String.to_integer()
    search_query = Map.get(params, "query")
    completed_onboarding = TeamUserQueries.completed_onboarding?(current_team, current_user)
    latest_source_map = SourceMap.latest_for_app(current_app)

    socket =
      socket
      |> assign(:page_title, "#{current_app.name} · #{current_team.name}")
      |> assign(:search_query, KsomniaWeb.SearchQuery.new(search_query))
      |> assign(:latest_source_map, latest_source_map)
      |> assign(:completed_onboarding, completed_onboarding)
      |> do_search(current_app, search_query, current_page)

    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_search_query", params, socket) do
    %{current_app: current_app} = LiveResource.get_assigns(socket)
    current_page = Map.get(params, "page", "1") |> String.to_integer()
    search_query = Map.get(params, "search_query_form_query", "")
    search_query_changeset = SearchQuery.new(search_query)

    {:noreply,
     socket
     |> assign(:search_query, search_query_changeset)
     |> do_search(current_app, search_query, current_page)}
  end

  def do_search(socket, app, search_query, current_page) do
    search_query = search_query && String.trim(search_query)
    index = "error_identities-app_id-#{app.id}"

    with true <- search_query != "" and search_query != nil,
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
