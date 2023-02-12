defmodule KsomniaWeb.AppLive.AppSettingsFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.App
  alias Ksomnia.Mutations.AppMutations

  @impl true
  def update(%{app: app} = assigns, socket) do
    changeset = App.changeset(app, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"app" => app_params}, socket) do
    changeset =
      socket.assigns.app
      |> App.changeset(app_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"app" => app_params}, socket) do
    save_app(socket, socket.assigns.action, app_params)
  end

  defp save_app(socket, :edit_app, app_params) do
    app = socket.assigns.app

    case AppMutations.update(app, app_params) do
      {:ok, app} ->
        {:noreply,
         socket
         |> put_flash(:info, "App updated successfully")
         |> push_navigate(to: ~p"/apps/#{app.id}/settings")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
