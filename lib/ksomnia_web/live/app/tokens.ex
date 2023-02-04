defmodule KsomniaWeb.AppLive.Tokens do
  use KsomniaWeb, :live_view

  alias Ksomnia.AppToken
  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.SourceMap

  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :settings]}
  on_mount {KsomniaWeb.AppLive.SettingsNavComponent, [set_section: :tokens]}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:display_token, nil)
      |> assign(:token_visibility_state, %{})

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    app = Repo.get(App, id)
    team = Repo.get(Ksomnia.Team, app.team_id)
    latest_source_map = SourceMap.latest_for_app(app)
    app_tokens = AppToken.all(app.id)

    socket =
      socket
      |> assign(:page_title, "#{app.name} · Settings · #{team.name}")
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:app_tokens, app_tokens)
      |> assign(:latest_source_map, latest_source_map)
      |> assign(:app_changeset, App.changeset(app, %{}))
      |> assign(:__current_app__, app.id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_token_visibility", %{"token" => token_id}, socket) do
    socket =
      assign(
        socket,
        :token_visibility_state,
        toggle_value(socket.assigns.token_visibility_state, token_id)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("generate_token", _value, socket) do
    user = socket.assigns.current_user
    app = socket.assigns.app

    AppToken.create(app.id, user.id)

    {:noreply,
     socket
     |> assign(:app_tokens, AppToken.all(app.id))}
  end

  def toggle_value(map, key) do
    case Map.get(map, key) do
      nil -> Map.put(map, key, true)
      true -> Map.put(map, key, false)
      false -> Map.put(map, key, true)
    end
  end
end
