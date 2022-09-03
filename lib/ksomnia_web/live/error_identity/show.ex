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
      |> assign(:display_stacktrace_type, "original")
      |> assign(:mapped_stacktrace, "")

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

    view_pid = self()

    spawn(fn ->
      case Ksomnia.SourceMapper.map_stacktrace(error_identity) do
        {:ok, %{body: %{"mapping" => _mappings, "mapped_stacktrace" => mapped_stacktrace}}} ->
          send(view_pid, {:map_stacktrace, mapped_stacktrace})

        _ ->
          nil
      end
    end)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show App"
  defp page_title(:edit), do: "Edit App"

  def commit_hash_abbriv(error_identity) do
    if error_identity.commit_hash do
      String.slice(error_identity.commit_hash, 0, 7)
    end
  end

  @impl true
  def handle_info({:map_stacktrace, result}, socket) do
    {:noreply, assign(socket, mapped_stacktrace: result)}
  end

  @impl true
  def handle_event("set_display_stacktrace_type", %{"type" => value}, socket) do
    {:noreply, assign(socket, :display_stacktrace_type, value)}
  end
end
