defmodule KsomniaWeb.ProjectLive.FormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.Project

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Project.changeset(project, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"project" => app_params}, socket) do
    changeset =
      socket.assigns.project
      |> Project.changeset(app_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"project" => app_params}, socket) do
    save_project(socket, socket.assigns.action, app_params)
  end

  defp save_project(socket, :edit, app_params) do
    case Project.update(socket.assigns.project, app_params) do
      {:ok, _app} ->
        {:noreply,
         socket
         |> put_flash(:info, "App updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_project(socket, :new, app_params) do
    user = socket.assigns.user

    case Project.create(user, app_params) do
      {:ok, _app} ->
        {:noreply,
         socket
         |> put_flash(:info, "App created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
