defmodule KsomniaWeb.TeamLive.Members do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.TeamUser
  alias Ksomnia.Permissions
  alias Ksomnia.Pagination
  alias KsomniaWeb.SearchQuery

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       team: nil,
       members: []
     })}
  end

  @impl true
  def handle_params(%{"team_id" => id} = params, _, socket) do
    team = Repo.get(Team, id)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Members")
      |> assign(:team, team)
      |> table_query(team, params)

    {:noreply, socket}
  end

  def handle_event("perform_search_query", params, socket) do
    team = socket.assigns.team
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
  def handle_event("remove-team-member", %{"team-member-id" => team_member_id}, socket) do
    target_user = User.get(team_member_id)
    current_user = socket.assigns.current_user
    team = socket.assigns.team

    with true <- Permissions.can_remove_user_from_team(team, current_user, target_user),
         %TeamUser{} <- TeamUser.remove_user(team, target_user) do
      socket = assign(socket, :team_members, User.for_team(team))
      {:noreply, socket}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp table_query(socket, team, params) do
    search_query = Map.get(params, "query")

    query =
      team
      |> User.for_team()
      |> User.search_by_username(search_query)

    socket
    |> Pagination.params_to_pagination(
      query,
      Map.merge(params, %{
        "query" => search_query
      })
    )
  end
end
