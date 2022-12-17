defmodule KsomniaWeb.TeamLive.Settings do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.Repo
  alias Ksomnia.App
  alias Ksomnia.Permissions

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       team: nil
     })}
  end

  @impl true
  def handle_params(%{"team_id" => id} = params, _, socket) do
    team = Repo.get(Team, id)

    socket =
      socket
      |> assign(:page_title, "#{team.name}")
      |> assign(:team, team)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_app, _params) do
    socket
    |> assign(:page_title, "New App")
    |> assign(:app, %App{team_id: socket.assigns.team.id})
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:page_title, socket.assigns.team.name)
  end

  @impl true
  def handle_event("leave-team", %{}, socket) do
    current_user = socket.assigns.current_user
    team = socket.assigns.team

    with true <- Permissions.can_leave_team(team, current_user),
         {:ok, _} <- TeamUser.remove_user(team, current_user) do
      {:noreply, push_navigate(socket, to: "/")}
    else
      _ ->
        {:noreply, socket}
    end
  end
end
