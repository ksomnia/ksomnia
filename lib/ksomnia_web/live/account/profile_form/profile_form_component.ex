defmodule KsomniaWeb.AppLive.ProfileFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.User

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = User.changeset(user, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user = socket.assigns.user

    case User.update_profile(user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> Phoenix.Flash.put_flash(:info, "User updated successfully")
         |> push_navigate(to: Routes.account_profile_path(socket, :profile))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
