defmodule KsomniaWeb.TeamLive.Invites do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.Invite
  alias Ksomnia.Permissions
  alias Ksomnia.Pagination
  alias KsomniaWeb.SearchQuery

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       team: nil,
       invites: []
     })}
  end

  @impl true
  def handle_params(%{"team_id" => id} = params, _, socket) do
    team = Repo.get(Team, id)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Pending invites")
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
  def handle_event("revoke-invite", %{"invite-id" => invite_id}, socket) do
    invite = Repo.get(Invite, invite_id)
    user = socket.assigns.current_user
    team = socket.assigns.team

    if Permissions.can_revoke_user_invite(team, user, invite) do
      Invite.revoke(invite)

      {:noreply, assign(socket, :invites, Invite.pending_for_team(team))}
    else
      {:noreply, socket}
    end
  end

  defp table_query(socket, team, params) do
    query =
      team
      |> Invite.pending_for_team()
      |> Invite.search_by_email(params["query"])

    socket
    |> Pagination.params_to_pagination(
      query,
      Map.merge(params, %{
        "query" => params["query"]
      })
    )
  end
end
