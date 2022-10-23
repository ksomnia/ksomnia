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
    case Invite.create(socket.assigns.team.id, params) do
      {:ok, _invite} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invite created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
