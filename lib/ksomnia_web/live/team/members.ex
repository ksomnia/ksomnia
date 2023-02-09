defmodule KsomniaWeb.TeamLive.Members do
  use KsomniaWeb, :live_view
  alias Ksomnia.User
  alias Ksomnia.TeamUser
  alias Ksomnia.Permissions
  alias Ksomnia.Pagination
  alias KsomniaWeb.SearchQuery
  alias KsomniaWeb.LiveResource
  alias Ksomnia.Queries.UserQueries

  @impl true
  def handle_params(params, _, socket) do
    %{current_team: team} = LiveResource.get_assigns(socket)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Members")
      |> table_query(team, params)

    {:noreply, socket}
  end

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
  def handle_event("remove-team-member", %{"team-member-id" => team_member_id} = params, socket) do
    %{current_team: current_team, current_user: current_user} = LiveResource.get_assigns(socket)

    with %User{} = target_user <- UserQueries.get(team_member_id),
         true <- Permissions.can_remove_user_from_team(current_team, current_user, target_user),
         {:ok, %TeamUser{}} <- TeamUser.remove_user(current_team, target_user) do
      {:noreply, table_query(socket, current_team, params)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp table_query(socket, team, params) do
    search_query = Map.get(params, "query")

    query =
      team
      |> UserQueries.for_team()
      |> UserQueries.search_by_username(search_query)

    socket
    |> Pagination.params_to_pagination(
      query,
      Map.merge(params, %{
        "query" => search_query
      })
    )
  end
end
