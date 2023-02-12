defmodule KsomniaWeb.TeamLive.AppFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.App
  alias Ksomnia.Mutations.AppMutations
  alias KsomniaWeb.LiveResource

  @impl true
  def update(assigns, socket) do
    changeset = App.changeset(%App{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"app" => app_params}, socket) do
    %{current_app: current_app} = LiveResource.get_assigns(socket)

    changeset =
      current_app
      |> App.changeset(app_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"app" => app_params}, socket) do
    save_app(socket, socket.assigns.action, app_params)
  end

  defp save_app(socket, :edit_app, app_params) do
    %{current_app: current_app} = LiveResource.get_assigns(socket)

    case AppMutations.update(current_app, app_params) do
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
    %{current_user: current_user} = LiveResource.get_assigns(socket)

    case AppMutations.create(socket.assigns.new_app_team_id, current_user.id, app_params) do
      {:ok, %{app: app}} ->
        {:noreply,
         socket
         |> put_flash(:info, "App created successfully")
         |> push_navigate(to: ~p"/apps/#{app.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
