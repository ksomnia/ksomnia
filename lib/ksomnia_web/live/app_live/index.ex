defmodule KsomniaWeb.AppLive.Index do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.App
  alias Ksomnia.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :apps, App.all())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit App")
    |> assign(:app, Repo.get(App, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New App")
    |> assign(:app, %App{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Apps")
    |> assign(:app, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    app = Repo.get(App, id)
    {:ok, _} = Repo.delete(app)

    {:noreply, assign(socket, :apps, App.all())}
  end
end
