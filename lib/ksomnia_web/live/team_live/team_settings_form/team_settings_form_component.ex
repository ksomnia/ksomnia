defmodule KsomniaWeb.AppLive.TeamSettingsFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.Team
  alias Ksomnia.Permissions

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Team.changeset(team, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"team" => params}, socket) do
    changeset =
      socket.assigns.team
      |> Team.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"team" => params}, socket) do
    save_app(socket, socket.assigns.action, params)
  end

  defp save_app(socket, :edit_team, params) do
    team = socket.assigns.team
    user = socket.assigns.current_user

    case Permissions.can_update_team(team, user) && Team.update(team, params) do
      {:ok, _app} ->
        {:noreply,
         socket
         |> Phoenix.Flash.put_flash(:info, "Team updated successfully")
         |> push_navigate(to: Routes.team_settings_path(socket, :settings, team))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
