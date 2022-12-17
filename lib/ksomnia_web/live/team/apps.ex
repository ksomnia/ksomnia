defmodule KsomniaWeb.TeamLive.Apps do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Repo
  alias Ksomnia.App

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :apps, [])}
  end

  @impl true
  def handle_params(%{"team_id" => id} = _params, _, socket) do
    team = Repo.get(Team, id)
    apps = App.for_team(team.id)

    socket =
      socket
      |> assign(:page_title, "#{team.name} · Apps")
      |> assign(:team, team)
      |> assign(:apps, apps)
      |> assign(:app, %{id: nil})

    {:noreply, socket}
  end
end
