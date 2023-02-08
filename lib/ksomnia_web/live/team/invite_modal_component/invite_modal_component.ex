defmodule KsomniaWeb.TeamLive.InviteModalComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.Invite
  alias KsomniaWeb.LiveResource

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Invite.new(team.id, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"invite" => params}, socket) do
    %{current_team: current_team} = LiveResource.get_assigns(socket)

    changeset =
      Invite.new(current_team.id, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"invite" => params}, socket) do
    %{current_team: current_team} = LiveResource.get_assigns(socket)

    case Invite.create(current_team.id, params) do
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
