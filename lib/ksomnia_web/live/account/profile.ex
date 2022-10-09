defmodule KsomniaWeb.AccountLive.Profile do
  use KsomniaWeb, :live_app_view
  alias Ksomnia.User

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :account}}

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns

    session =
      socket
      |> assign(:changeset, User.changeset(user, %{}))
      |> assign(:team, nil)

    {:ok, session}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
