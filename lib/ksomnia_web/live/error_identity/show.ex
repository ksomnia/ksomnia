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
      |> assign(:mappings, [])
      |> assign(:code_context, [])

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
        {:ok,
         %{
           body: %{
             "mapping" => mappings,
             "mapped_stacktrace" => mapped_stacktrace,
             "sources" => sources
           }
         }} ->
          opts = %{
            map_stacktrace: mapped_stacktrace,
            mappings: mappings,
            sources: sources
          }

          send(view_pid, opts)

        _ ->
          nil
      end
    end)

    {:noreply, socket}
  end

  def code_snippet(mappings) do
    lines =
      for {line, i} <- Enum.with_index(mappings) do
        formatted_line = line["formattedLine"]
        left_half = String.slice(formatted_line, 0, line["column"])

        left =
          content_tag(:span, left_half,
            class: "whitespace-pre-wrap border-r-2 border-red-300 py-1"
          )

        right_half = String.slice(formatted_line, line["column"], String.length(formatted_line))

        right = content_tag(:span, right_half, class: "whitespace-pre-wrap py-1")

        content_tag(:div, [left, right],
          class: "block group w-full hover:bg-indigo-100 cursor-pointer",
          "phx-click": "set_line_context",
          "phx-value-line": i
        )
      end

    code = content_tag(:code, lines)
    content_tag(:pre, code, class: "mt-5 code-snippet")
  end

  def source_snippet(source) do
    lines =
      for {line, i} <- Enum.with_index(source) do
        code_line =
          content_tag(:span, if(line == "", do: " ", else: line),
            class: "whitespace-pre-wrap py-1"
          )

        content_tag(:div, code_line,
          class:
            "block group w-full hover:bg-indigo-100 cursor-pointer " <>
              if(i == 3, do: "bg-indigo-100", else: "")
        )
      end

    code = content_tag(:code, lines)
    content_tag(:pre, code, class: "mt-5 code-snippet")
  end

  defp page_title(:show), do: "Show App"
  defp page_title(:edit), do: "Edit App"

  @impl true
  def handle_info(opts, socket) do
    {:noreply, assign(socket, opts)}
  end

  @impl true
  def handle_event("set_display_stacktrace_type", %{"type" => value}, socket) do
    {:noreply, assign(socket, :display_stacktrace_type, value)}
  end

  @impl true
  def handle_event("set_line_context", %{"line" => line}, socket) do
    sources = socket.assigns.sources
    {line, ""} = Integer.parse(line)
    map = Enum.at(socket.assigns.mappings, line)
    source = sources[map["source"]]
    {:noreply, assign(socket, :code_context, surr(source, map["line"]))}
  end

  def surr(source, line) do
    source
    |> String.split(~r/\n/)
    |> Enum.slice(line - 4, 7)
  end
end
