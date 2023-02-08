defmodule KsomniaWeb.TeamLive.Settings do
  use KsomniaWeb, :live_view
  alias Ksomnia.TeamUser
  alias Ksomnia.Permissions
  alias KsomniaWeb.LiveResource

  @impl true
  def handle_params(_params, _, socket) do
    %{current_team: current_team} = LiveResource.get_assigns(socket)

    socket =
      socket
      |> assign(:page_title, "#{current_team.name}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("leave-team", %{}, socket) do
    %{current_team: current_team, current_user: current_user} = LiveResource.get_assigns(socket)

    with true <- Permissions.can_leave_team(current_team, current_user),
         {:ok, _} <- TeamUser.remove_user(current_team, current_user) do
      {:noreply, push_navigate(socket, to: "/")}
    else
      _ ->
        {:noreply, socket}
    end
  end
end
