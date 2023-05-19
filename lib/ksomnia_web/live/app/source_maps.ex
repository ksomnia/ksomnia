defmodule KsomniaWeb.AppLive.SourceMaps do
  use KsomniaWeb, :live_view
  alias Ksomnia.Queries.SourceMapQueries
  alias Ksomnia.Pagination
  alias KsomniaWeb.LiveResource

  on_mount {KsomniaWeb.AppLive.NavComponent, [set_section: :source_maps]}

  @impl true
  def handle_params(params, _, socket) do
    %{current_team: current_team, current_app: current_app} = LiveResource.get_assigns(socket)
    current_page = Map.get(params, "page", "1") |> String.to_integer()

    pagination =
      current_app
      |> SourceMapQueries.for_app()
      |> Pagination.paginate(current_page)

    socket =
      socket
      |> assign(:page_title, "#{current_app.name} · Source maps · #{current_team.name}")
      |> assign(:pagination, pagination)

    {:noreply, socket}
  end
end
