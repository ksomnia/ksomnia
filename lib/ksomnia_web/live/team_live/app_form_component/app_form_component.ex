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
    case App.create(socket.assigns.team_id, app_params) do
      {:ok, _app} ->
        {:noreply,
         socket
        #  |> Phoenix.Flash.put_flash(:info, "App created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.modal id="confirm-modal">
        Are you sure? ^)^
        <div>
        <%= assigns |> Map.keys() |> Enum.join(", ") %>
        <pre>
        <%= "> [#{assigns[:new_app_team_id]}] <" %>
        </pre>
        </div>
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
    </div>
    """
  end
end
