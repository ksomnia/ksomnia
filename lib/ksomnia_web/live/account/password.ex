defmodule KsomniaWeb.AccountLive.Password do
  use KsomniaWeb, :live_view

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :account}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
