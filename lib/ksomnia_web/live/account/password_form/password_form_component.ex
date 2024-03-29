defmodule KsomniaWeb.AppLive.PasswordFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.User
  alias Ksomnia.Mutations.UserMutations

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = User.new_password_changeset(user, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => new_password_params}, socket) do
    changeset =
      socket.assigns.user
      |> User.new_password_changeset(new_password_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => new_password_params}, socket) do
    user = socket.assigns.user

    case UserMutations.change_password(user, new_password_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully")
         |> push_navigate(to: ~p"/account/profile/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
