defmodule KsomniaWeb.AppLive.AppSettingsFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.App

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

    case App.update(app, app_params) do
      {:ok, _app} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/t/#{app.id}/settings")}

        #  |> Phoenix.Flash.put_flash(:info, "App updated successfully")
        #  |> push_navigate(to: Routes.app_settings_path(socket, :settings, app))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
