defmodule KsomniaWeb.DashboardLive.Index do
  use KsomniaWeb, :live_view

  alias Ksomnia.App

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :dashboard}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :apps, App.all())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Dashboard")
  end
end
