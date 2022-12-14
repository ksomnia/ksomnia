defmodule KsomniaWeb.TeamLive.Index do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Invite

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns
    changeset = Team.changeset(%Team{}, %{})

    session =
      socket
      |> assign(:teams, Team.for_user(user))
      |> assign(:invites, Invite.for_user_email(user.email))
      |> assign(:team, %Team{})
      |> assign(:changeset, changeset)

    {:ok, session}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket =
      socket
      |> assign(:page_title, "Teams")

    {:noreply, socket}
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
         |> push_navigate(to: "/t/#{team.id}/apps")}

      {:error, %{team: %Ecto.Changeset{} = changeset}} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("accept-invite", %{"invite-id" => invite_id}, socket) do
    user = socket.assigns.current_user

    case Invite.accept(invite_id, user) do
      {:ok, _} ->
        socket =
          socket
          |> assign(:teams, Team.for_user(user))
          |> assign(:invites, Invite.for_user_email(user.email))

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("reject-invite", %{"invite-id" => invite_id}, socket) do
    user = socket.assigns.current_user

    case Invite.reject(invite_id, user) do
      {:ok, _} ->
        socket =
          socket
          |> assign(:invites, Invite.for_user_email(user.email))

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
