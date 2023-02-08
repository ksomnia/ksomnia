defmodule KsomniaWeb.TeamLive.Apps do
  use KsomniaWeb, :live_view
  alias Ksomnia.Repo
  alias Ksomnia.App
  alias KsomniaWeb.SearchQuery
  alias KsomniaWeb.LiveResource

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :apps, [])}
  end

  @impl true
  def handle_params(params, _, socket) do
    %{current_team: team} = LiveResource.get_assigns(socket)
    search_query = Map.get(params, "query")

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Apps")
      |> assign(:search_query, KsomniaWeb.SearchQuery.new(search_query))
      |> table_query(
        team,
        Map.merge(params, %{
          "query" => search_query
        })
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("perform_search_query", params, socket) do
    %{current_team: team} = LiveResource.get_assigns(socket)
    search_query = Map.get(params, "search_query_form_query", "")
    search_query_changeset = SearchQuery.new(search_query)

    {:noreply,
     socket
     |> assign(:search_query, search_query_changeset)
     |> table_query(
       team,
       Map.merge(params, %{
         "query" => search_query
       })
     )}
  end

  defp table_query(socket, team, params) do
    apps =
      team.id
      |> App.for_team()
      |> App.search_by_name(params["query"])
      |> Repo.all()

    socket
    |> assign(:apps, apps)
    |> assign(:search_query, KsomniaWeb.SearchQuery.new(params["query"]))
  end
end
