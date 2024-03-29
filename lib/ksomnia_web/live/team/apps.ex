defmodule KsomniaWeb.TeamLive.Apps do
  use KsomniaWeb, :live_view
  alias Ksomnia.Repo
  alias Ksomnia.Queries.AppQueries
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

  @impl true
  def handle_event("set-new-app-modal-data", %{"team-id" => team_id}, socket) do
    send_update(KsomniaWeb.TeamLive.AppFormComponent, id: :new_app_modal, new_app_team_id: team_id)

    {:noreply, socket}
  end

  defp table_query(socket, team, params) do
    apps =
      team.id
      |> AppQueries.for_team()
      |> AppQueries.search_by_name(params["query"])
      |> Repo.all()

    socket
    |> assign(:apps, apps)
    |> assign(:search_query, KsomniaWeb.SearchQuery.new(params["query"]))
  end
end
