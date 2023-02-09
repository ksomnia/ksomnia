defmodule KsomniaWeb.TeamLive.Invites do
  use KsomniaWeb, :live_view
  alias Ksomnia.Repo
  alias Ksomnia.Invite
  alias Ksomnia.Permissions
  alias Ksomnia.Pagination
  alias KsomniaWeb.SearchQuery
  alias KsomniaWeb.LiveResource

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       team: nil,
       invites: []
     })}
  end

  @impl true
  def handle_params(params, _, socket) do
    %{current_team: team} = LiveResource.get_assigns(socket)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Pending invites")
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
  def handle_event("revoke-invite", %{"invite-id" => invite_id} = params, socket) do
    %{current_team: current_team, current_user: current_user} = LiveResource.get_assigns(socket)
    invite = Repo.get(Invite, invite_id)

    if Permissions.can_revoke_user_invite(current_team, current_user, invite) do
      Invite.revoke(invite)
      {:noreply, table_query(socket, current_team, params)}
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
