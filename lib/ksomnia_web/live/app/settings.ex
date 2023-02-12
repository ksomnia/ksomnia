defmodule KsomniaWeb.AppLive.Settings do
  use KsomniaWeb, :live_view
  alias Ksomnia.App
  alias Ksomnia.Avatar
  alias Ksomnia.Mutations.AppMutations
  alias KsomniaWeb.LiveResource

  on_mount({KsomniaWeb.AppLive.NavComponent, [set_section: :settings]})

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _, socket) do
    %{current_team: current_team, current_app: current_app} = LiveResource.get_assigns(socket)

    socket =
      socket
      |> assign(:page_title, "#{current_app.name} · Settings · #{current_team.name}")
      |> assign(:changeset, App.changeset(current_app, %{}))

    {:noreply, socket}
  end

  def handle_event("save", %{"app" => params}, socket) do
    %{current_app: current_app} = LiveResource.get_assigns(socket)
    params = Avatar.consume(socket, params, "apps", current_app)

    case AppMutations.update(current_app, params) do
      {:ok, app} ->
        {:noreply,
         socket
         |> put_flash(:info, "App updated successfully")
         |> push_navigate(to: ~p"/apps/#{app.id}/settings")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("validate", app_params, socket) do
    %{current_app: current_app} = LiveResource.get_assigns(socket)

    changeset =
      current_app
      |> App.changeset(app_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
