defmodule KsomniaWeb.AppLive.Tokens do
  use KsomniaWeb, :live_view

  alias Ksomnia.AppToken
  alias Ksomnia.App
  alias Ksomnia.Repo
  alias Ksomnia.SourceMap
  alias Ksomnia.Util

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
  def handle_params(%{"id" => id} = params, _, socket) do
    app = Repo.get(App, id)
    team = Repo.get(Ksomnia.Team, app.team_id)
    latest_source_map = SourceMap.latest_for_app(app)

    query = AppToken.all(app.id)

    socket =
      socket
      |> assign(:page_title, "#{app.name} · Settings · #{team.name}")
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:latest_source_map, latest_source_map)
      |> assign(:app_changeset, App.changeset(app, %{}))
      |> assign(:__current_app__, app.id)
      |> Pagination.params_to_pagination(query, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_token_visibility", %{"token" => token_id}, socket) do
    token_visibility_state = socket.assigns.token_visibility_state

    socket =
      socket
      |> assign(:token_visibility_state, Util.toggle_value(token_visibility_state, token_id))

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

  def handle_event("revoke-token", %{"id" => app_token_id}, socket) do
    with %AppToken{} = app_token <- Repo.get(AppToken, app_token_id),
         {:ok, app_token} <- AppToken.revoke(app_token) do
      {:noreply, assign(socket, :app_tokens, AppToken.all(app_token.app_id))}
    else
      _error -> socket
    end
  end
end
