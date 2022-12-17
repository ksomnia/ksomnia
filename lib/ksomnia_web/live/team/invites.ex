defmodule KsomniaWeb.TeamLive.Invites do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.Invite
  alias Ksomnia.Permissions

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :invites}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       team: nil,
       invites: []
     })}
  end

  @impl true
  def handle_params(%{"team_id" => id} = _params, _, socket) do
    team = Repo.get(Team, id)
    invites = Invite.pending_for_team(team)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Pending invites")
      |> assign(:team, team)
      |> assign(:invites, invites)

    {:noreply, socket}
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
end
