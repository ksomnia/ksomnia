defmodule KsomniaWeb.TeamLive.Index do
  use KsomniaWeb, :live_app_view
  alias Ksomnia.Team

  on_mount {KsomniaWeb.Live.SidebarHighlight, %{section: :projects}}

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns
    changeset = Team.changeset(%Team{}, %{})

    session =
      socket
      |> assign(:teams, Team.for_user(user))
      |> assign(:team, %Team{})
      |> assign(:changeset, changeset)

    {:ok, session}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"team" => params}, socket) do
    changeset =
      socket.assigns.team
      |> Team.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"team" => params}, socket) do
    case Team.create(socket.assigns.current_user, params) do
      {:ok, %{team: team}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> push_redirect(to: "/t/#{team.id}")}

      {:error, %{team: %Ecto.Changeset{} = changeset}} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end


  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Teams")
  end
end
