defmodule KsomniaWeb.TeamLive.Index do
  use KsomniaWeb, :live_view
  alias Ksomnia.Team
  alias Ksomnia.Queries.TeamQueries
  alias Ksomnia.Queries.InviteQueries
  alias Ksomnia.Mutations.TeamMutations
  alias Ksomnia.Mutations.InviteMutations
  alias KsomniaWeb.LiveResource

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: user} = LiveResource.get_assigns(socket)
    changeset = Team.changeset(%Team{}, %{})
    teams = TeamQueries.for_user(user)

    session =
      socket
      |> assign(:teams, teams)
      |> assign(:invites, InviteQueries.for_user_email(user.email))
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
      %Team{}
      |> Team.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"team" => params}, socket) do
    %{current_user: user} = LiveResource.get_assigns(socket)

    case TeamMutations.create(user, params) do
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
    %{current_user: user} = LiveResource.get_assigns(socket)

    case InviteMutations.accept(invite_id, user) do
      {:ok, _} ->
        socket =
          socket
          |> assign(:teams, TeamQueries.for_user(user))
          |> assign(:invites, InviteQueries.for_user_email(user.email))

        {:noreply, socket}

      {:error, _, _, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("reject-invite", %{"invite-id" => invite_id}, socket) do
    %{current_user: user} = LiveResource.get_assigns(socket)

    case InviteMutations.reject(invite_id, user) do
      {:ok, _} ->
        socket =
          socket
          |> assign(:invites, InviteQueries.for_user_email(user.email))

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
