defmodule KsomniaWeb.AppLive.TeamSettingsFormComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.Team
  alias Ksomnia.Mutations.TeamMutations
  alias Ksomnia.Permissions
  alias Ksomnia.Avatar

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Team.changeset(team, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
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
    params = Avatar.consume(socket, params, "teams", team)

    case Permissions.can_update_team(team, user) && TeamMutations.update(team, params) do
      {:ok, _app} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> push_navigate(to: ~p"/t/#{team.id}/settings")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
