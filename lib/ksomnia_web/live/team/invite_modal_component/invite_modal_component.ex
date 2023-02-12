defmodule KsomniaWeb.TeamLive.InviteModalComponent do
  use KsomniaWeb, :live_component
  alias KsomniaWeb.LiveResource
  alias Ksomnia.Invite
  alias Ksomnia.Mutations.InviteMutations

  @impl true
  def update(assigns, socket) do
    %{current_team: current_team, current_user: current_user} = LiveResource.get_assigns(assigns)
    changeset = Invite.new(current_team.id, current_user.id, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"invite" => params}, socket) do
    %{current_team: current_team, current_user: current_user} = LiveResource.get_assigns(socket)

    changeset =
      Invite.new(current_team.id, current_user.id, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"invite" => params}, socket) do
    %{current_team: current_team, current_user: current_user} = LiveResource.get_assigns(socket)

    case InviteMutations.create(current_team.id, current_user.id, params) do
      {:ok, _invite} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invite created successfully")
         |> push_navigate(to: ~p"/t/#{current_team.id}/members/invites")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
