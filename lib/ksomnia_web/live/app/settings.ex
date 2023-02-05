defmodule KsomniaWeb.AppLive.Settings do
  use KsomniaWeb, :live_view

  alias Ksomnia.App
  alias Ksomnia.Repo

  on_mount({KsomniaWeb.AppLive.NavComponent, [set_section: :settings]})

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    app = Repo.get(App, id)
    team = Repo.get(Ksomnia.Team, app.team_id)

    socket =
      socket
      |> assign(:page_title, "#{app.name} · Settings · #{team.name}")
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:__current_app__, app.id)
      |> assign(:changeset, App.changeset(app, %{}))

    {:noreply, socket}
  end

  def handle_event("save", %{"app" => params}, socket) do
    app = socket.assigns.app

    params = Ksomnia.Avatar.consume(socket, params, "apps", app)

    case App.update(app, params) do
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
    changeset =
      socket.assigns.app
      |> App.changeset(app_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("upload_file", %{"file" => file}, socket) do
    {:ok, content} = File.read(file.path)

    {:noreply, assign(socket, :file_content, content)}
  end
end
