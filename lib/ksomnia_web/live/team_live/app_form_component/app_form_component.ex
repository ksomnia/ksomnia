defmodule KsomniaWeb.TeamLive.AppFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.App

  @impl true
  def update(%{app: app} = assigns, socket) do
    # dbg({:UPDATE!, assigns})
    IO.inspect({:assigns, assigns})
    changeset = App.changeset(app, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
    }
    #  |> assign(:new_app_team_id, nil)}
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
      {:ok, _app} ->
        {:noreply,
         socket
        #  |> Phoenix.Flash.put_flash(:info, "App updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

         #  |> put_flash(:info, "App updated successfully")

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_app(socket, :new_app, app_params) do
    case App.create(socket.assigns.new_app_team_id, app_params) do
      {:ok, app} ->
        {:noreply,
         socket
         # |> Phoenix.Flash.put_flash(:info, "App created successfully")
         |> push_navigate(to: ~p"/apps/#{app.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.modal id="confirm-modal">
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
          <%= "[#{assigns[:new_app_team_id]}]" %>
          <div class="mt-3 text-center sm:mt-0 sm:ml-0 sm:text-left">
            <div class="mt-5 sm:mt-6 sm:grid sm:grid-cols-2 sm:gap-3 sm:grid-flow-row-dense">
              <.button phx-disable-with="Saving...">Create this app</.button>
              <%= live_patch "Cancel", to: @return_to, class: "btn-default mt-3 w-full inline-flex justify-center sm:mt-0 sm:col-start-1 sm:text-sm" %>
            </div>
          </div>
        </.simple_form>

        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
    </div>
    """
  end
end
