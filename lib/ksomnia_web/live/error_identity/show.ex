defmodule KsomniaWeb.ErrorIdentityLive.Show do
  use KsomniaWeb, :live_app_view

  alias Ksomnia.Repo
  alias Ksomnia.ErrorRecord
  alias Ksomnia.ErrorIdentity

  on_mount {KsomniaWeb.Live.SidebarHighlight, [set_section: :projects]}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:display_token, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    error_identity = Repo.preload(Repo.get(ErrorIdentity, id), app: :project)
    app = error_identity.app
    project = error_identity.app.project
    error_records = ErrorRecord.for_error_identity(error_identity)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:error_identity, error_identity)
      |> assign(:app, app)
      |> assign(:project, project)
      |> assign(:error_records, error_records)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show App"
  defp page_title(:edit), do: "Edit App"
end
