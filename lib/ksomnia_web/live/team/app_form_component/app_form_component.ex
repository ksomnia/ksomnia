defmodule KsomniaWeb.TeamLive.AppFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.App

  @impl true
  def update(%{app: app} = assigns, socket) do
    changeset = App.changeset(app, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
    }
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
    case App.update(socket.assigns.app, app_params) do
      {:ok, app} ->
        {:noreply,
         socket
         |> put_flash(:info, "App updated successfully")
         |> push_navigate(to: ~p"/apps/#{app.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_app(socket, :new_app, app_params) do
    case App.create(socket.assigns.new_app_team_id, app_params) do
      {:ok, app} ->
        {:noreply,
         socket
         |> put_flash(:info, "App created successfully")
         |> push_navigate(to: ~p"/apps/#{app.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.modal id="new-app-modal">
        <.simple_form
          let={f}
          for={@changeset}
          id="app-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save">
          <div class="sm:flex sm:items-start">
            <div class="mt-3 text-center sm:mt-0 sm:ml-0 sm:text-left">
              <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">New app</h3>
              <div class="mt-10 mb-5">
                <.input field={{f, :name}} type="text" label="App name" />
              </div>
            </div>
          </div>
          <div class="mt-3 text-center sm:mt-0 sm:ml-0 sm:text-left">
            <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
              <.button
                phx-click={hide_modal(%JS{}, "new-app-modal")}
                class="btn-default text-gray-900"
              >
                Cancel
              </.button>
              <.button
                phx-disable-with="Saving...">
                Create this app
              </.button>
            </div>
          </div>
        </.simple_form>
      </.modal>
    </div>
    """
  end
end
