defmodule KsomniaWeb.LiveResource do
  import Phoenix.Component
  import Phoenix.LiveView
  use KsomniaWeb, :html
  alias Ksomnia.Team
  alias Ksomnia.App
  alias Ksomnia.User
  alias KsomniaWeb.LiveResource

  defstruct [:current_user, :current_team, :current_app]

  @type t() :: %LiveResource{
    current_user: %User{},
    current_team: %Team{},
    current_app: %App{},
  }

  @spec get_assigns(Phoenix.LiveView.Socket.t()) :: LiveResource.t()
  def get_assigns(%{assigns: assigns}) do
    assigns
  end

  def on_mount(:set_current_resources, %{"team_id" => team_id}, _session, socket) do
    with %Team{} = team <- Team.get(team_id) do
      socket =
        socket
        |> assign(:current_team, team)

      {:cont, socket}
    else
      _ ->
        {:halt, redirect(socket, to: ~p"/teams")}
    end
  end

  def on_mount(:set_current_resources, %{"app_id" => app_id}, _session, socket) do
    with %App{} = app <- App.get(app_id),
         %Team{} = team <- Team.get(app.team_id) do
      socket =
        socket
        |> assign(:current_app, app)
        |> assign(:current_team, team)

      {:cont, socket}
    else
      _ ->
        {:halt, redirect(socket, to: ~p"/teams")}
    end
  end

  def on_mount(:set_current_resources, _paarms, _session, socket) do
    {:cont, socket}
  end
end
