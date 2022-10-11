defmodule KsomniaWeb.TeamLive.Apps do
  use KsomniaWeb, :live_app_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.App

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :apps, [])}
  end

  @impl true
  def handle_params(%{"team_id" => id} = params, _, socket) do
    team = Repo.get(Team, id)
    apps = App.for_team(team.id)

    socket =
      socket
      |> assign(:team, team)
      |> assign(:apps, apps)
      |> assign(:page_title, "#{team.name}")
      |> assign(:app, %{id: nil})

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
end
