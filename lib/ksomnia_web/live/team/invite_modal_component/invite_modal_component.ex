defmodule KsomniaWeb.TeamLive.InviteModalComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.Invite

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
    changeset =
      Invite.new(socket.assigns.team.id, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"invite" => params}, socket) do
    team = socket.assigns.team

    case Invite.create(team.id, params) do
      {:ok, _invite} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invite created successfully")
         |> push_navigate(to: ~p"/t/#{team.id}/members/invites")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
