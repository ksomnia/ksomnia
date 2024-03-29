defmodule KsomniaWeb.AppLive.Tokens do
  use KsomniaWeb, :live_view
  alias Ksomnia.AppToken
  alias Ksomnia.App
  alias Ksomnia.Util
  alias Ksomnia.Queries.AppTokenQueries
  alias Ksomnia.Mutations.AppTokenMutations
  alias KsomniaWeb.LiveResource

  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :tokens]}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:token_visibility_state, %{})

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    %{current_team: current_team, current_app: current_app} = LiveResource.get_assigns(socket)
    query = AppTokenQueries.all(current_app.id)

    socket =
      socket
      |> assign(:page_title, "#{current_app.name} · Settings · #{current_team.name}")
      |> assign(:app_changeset, App.changeset(current_app, %{}))
      |> assign(:__current_app__, current_app.id)
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
  def handle_event("generate_token", params, socket) do
    %{current_user: current_user, current_app: current_app} = LiveResource.get_assigns(socket)
    AppTokenMutations.create(current_app.id, current_user.id)

    {:noreply, table_query(socket, current_app, params)}
  end

  def handle_event("revoke-token", %{"id" => app_token_id} = params, socket) do
    with %AppToken{} = app_token <- AppTokenQueries.find_by_id(app_token_id),
         {:ok, _app_token} <- AppTokenMutations.revoke(app_token) do
      {:noreply, table_query(socket, app_token.app, params)}
    else
      _error -> socket
    end
  end

  defp table_query(socket, app, params) do
    query = AppTokenQueries.all(app.id)

    socket
    |> Pagination.params_to_pagination(
      query,
      Map.merge(params, %{
        "query" => params["query"]
      })
    )
  end
end
