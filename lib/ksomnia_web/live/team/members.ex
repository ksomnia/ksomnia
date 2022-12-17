defmodule KsomniaWeb.TeamLive.Members do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.TeamUser
  alias Ksomnia.Permissions

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

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
    team_members = User.for_team(team)

    socket =
      socket
      |> assign(:team, team)
      |> assign(:team_members, team_members)
      |> assign(:page_title, "#{team.name}")

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:page_title, socket.assigns.team.name)
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
end
