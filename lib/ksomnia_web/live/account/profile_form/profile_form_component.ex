defmodule KsomniaWeb.AppLive.ProfileFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.User
  alias Ksomnia.Mutations.UserMutations
  alias Ksomnia.Avatar

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = User.changeset(user, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => params}, socket) do
    user = socket.assigns.user
    params = Avatar.consume(socket, params, "apps", user)

    case UserMutations.update_profile(user, params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account updated successfully")
         |> push_navigate(to: ~p"/account/profile/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
