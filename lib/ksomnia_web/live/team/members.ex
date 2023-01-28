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
    current_page = Map.get(params, "page", "1") |> String.to_integer()
    search_query = Map.get(params, "query")

    pagination =
      team
      |> User.for_team()
      |> User.search_by_username(search_query)
      |> Pagination.paginate(current_page)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Members")
      |> assign(:team, team)
      |> assign(:pagination, pagination)
      |> assign(:search_query, SearchQuery.new(search_query))

    {:noreply, socket}
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

  def handle_event("perform_search_query", params, socket) do
    search_query = Map.get(params, "search_query_form_query", "")
    search_query_changeset = SearchQuery.new(search_query)
    pagination = socket.assigns.pagination
    team = socket.assigns.team

    pagination =
      team
      |> User.for_team()
      |> User.search_by_username(search_query)
      |> Pagination.paginate(pagination.current_page)

    {:noreply,
      socket
      |> assign(:search_query, search_query_changeset)
      |> assign(:pagination, pagination)
    }
  end

  def page_query_string(page, search_query) do
    %{}
    |> Ksomnia.Util.add_if("page", page)
    |> Ksomnia.Util.add_if("query", SearchQuery.query(search_query))
    |> Enum.reduce("?", fn ({k, v}, acc) ->
      "#{acc}#{k}=#{v}&"
    end)
  end
end
