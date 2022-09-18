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
      |> assign(:mappings, [])
      |> assign(:line_source_context, [])
      |> assign(:current_line, 0)

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
             "mappings" => mappings,
             "sources" => sources
           }
         }} ->
          opts = %{
            mappings: mappings,
            sources: sources,
            line_source_context: set_line_context(sources, mappings, 0)
          }

          send(view_pid, opts)

        _ ->
          nil
      end
    end)

    {:noreply, socket}
  end

  def code_snippet(mappings, current_line, error_identity_message) do
    max_line_num_len =
      Enum.map(mappings, & &1["line"])
      |> case do
        [] -> 0
        lines -> Enum.max(lines)
      end
      |> Integer.to_string()
      |> String.length()

    lines =
      for {line, i} <- Enum.with_index(mappings) do
        formatted_line = line["formattedLine"]
        left_half = String.slice(formatted_line, 0, line["column"])

        line_num =
          content_tag(:span, String.pad_leading("#{line["line"]}", max_line_num_len, " "),
            class: "text-slate-400"
          )

        left = content_tag(:span, [line_num, left_half], class: "border-r-2 border-red-300 py-1")

        right_half = String.slice(formatted_line, line["column"], String.length(formatted_line))

        source = content_tag(:span, " #{Path.basename(line["source"])}", class: "text-slate-400")

        right = content_tag(:span, [right_half, source], class: "py-1")

        content_tag(:div, [left, right],
          class:
            "group w-full hover:bg-indigo-100 cursor-pointer whitespace-nowrap pl-2 " <>
              if(current_line == i, do: " bg-indigo-100", else: ""),
          "phx-click": "set_line_context",
          "phx-value-line": i
        )
      end

    message =
      content_tag(:div, error_identity_message, class: "block group w-full text-xs mb-1 pl-2 ")

    code = content_tag(:code, [message | lines])
    content_tag(:pre, code, class: "code-snippet")
  end

  def render_line_source_context(mappings, current_line, source, error_identity_message) do
    current_line_map = Enum.at(mappings, current_line)
    source_file_name = current_line_map["source"]
    dbg(current_line_map)

    max_line_num_len =
      Enum.map(source, fn {_, i} -> i end)
      |> case do
        [] -> 0
        lines -> Enum.max(lines)
      end
      |> Integer.to_string()
      |> String.length()

    lines =
      for {line, i} <- source do
        {line, i}

        line_num =
          content_tag(
            :span,
            String.pad_leading("#{i + 1} ", max_line_num_len, " "),
            class: "text-slate-400 select-none"
          )

        if i + 1 == current_line_map["line"] do
          code_line_left_half = String.slice(line, 0, current_line_map["column"])

          code_line_right_half =
            String.slice(line, current_line_map["column"], String.length(line))

          code_line_left_tag =
            content_tag(:span, [line_num, code_line_left_half],
              class: "border-r-2 border-orange-400 py-1"
            )

          code_line_right_tag = content_tag(:span, [code_line_right_half], class: "py-1")

          hint =
            content_tag(:div, error_identity_message,
              class:
                "absolute -top-2 left-7 text-xs bg-orange-200 text-orange-900 opacity-70 px-1 rounded-xs select-none invisible group-hover:visible "
            )

          content_tag(:div, [code_line_left_tag, code_line_right_tag, hint],
            class: "group w-full bg-orange-100 whitespace-pre-wrap pl-2 relative "
          )
        else
          code_line =
            content_tag(
              :span,
              if(line == "", do: " ", else: line),
              class: "whitespace-pre-wrap py-1"
            )

          content_tag(:div, [line_num, code_line], class: "group w-full pl-2 whitespace-nowrap")
        end
      end

    message =
      content_tag(:div, source_file_name,
        class: "block group w-full text-xs mb-1 text-slate-400 whitespace-nowrap pl-2"
      )

    code = content_tag(:code, [message | lines])
    content_tag(:pre, code, class: "code-snippet")
  end

  def bare_code_snippet(content) do
    code = content_tag(:code, content)
    content_tag(:pre, code, class: "code-snippet px-2")
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
    {line, ""} = Integer.parse(line)
    sources = socket.assigns.sources
    mappings = socket.assigns.mappings
    line_context = set_line_context(sources, mappings, line)
    socket = assign(socket, line_source_context: line_context, current_line: line)
    {:noreply, socket}
  end

  def set_line_context(sources, mappings, line) do
    map = Enum.at(mappings, line)

    sources[map["source"]]
    |> String.split(~r/\n/)
    |> Enum.with_index()
    |> Enum.slice(map["line"] - 4, 7)
  end
end
