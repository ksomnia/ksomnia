defmodule KsomniaWeb.TeamLive.Index do
  use KsomniaWeb, :live_app_view
  alias Ksomnia.Team
  alias Ksomnia.Repo

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns

    session =
      socket
      |> assign(:teams, Team.for_user(user))

    {:ok, session}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Teams")
  end
end
