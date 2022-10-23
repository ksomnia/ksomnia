defmodule KsomniaWeb.TeamLive.Invites do
  use KsomniaWeb, :live_app_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.Invite

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{
      team: nil,
      invites: []
    })}
  end

  @impl true
  def handle_params(%{"team_id" => id} = params, _, socket) do
    team = Repo.get(Team, id)
    invites = Invite.pending_for_team(team)

    socket =
      socket
      |> assign(:team, team)
      |> assign(:invites, invites)
      |> assign(:page_title, "#{team.name}")

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:page_title, socket.assigns.team.name)
  end
end
