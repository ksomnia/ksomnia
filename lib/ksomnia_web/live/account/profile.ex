defmodule KsomniaWeb.AccountLive.Profile do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.Project
  alias Ksomnia.Repo
  alias Ksomnia.User

  on_mount {KsomniaWeb.Live.SidebarHighlight, [set_section: :account]}

  @impl true
  def mount(_params, session, socket) do
    %{current_user: user} = socket.assigns

    session =
      socket
      |> assign(:changeset, User.changeset(user, %{}))

    {:ok, session}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end
end
