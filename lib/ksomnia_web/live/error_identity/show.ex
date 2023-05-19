defmodule KsomniaWeb.ErrorIdentityLive.Show do
  use KsomniaWeb, :live_view
  import Phoenix.HTML.Tag
  alias Ksomnia.Repo
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.SourceMapper
  alias Ksomnia.Queries.ErrorEventQueries

  @stacktrace_types ["source_map", "generated_source"]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:stacktrace_type, "source_map")
      |> assign(:mappings, [])
      |> assign(:current_line, 0)
      |> assign(:sources, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    error_identity = Repo.preload(Repo.get(ErrorIdentity, id), app: :team)
    app = error_identity.app
    team = error_identity.app.team

    entries =
      error_identity
      |> ErrorEventQueries.for_error_identity()

    socket =
      socket
      |> assign(:page_title, error_identity.message)
      |> assign(:error_identity, error_identity)
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:entries, entries)
      |> assign(:__current_app__, app.id)

    view_pid = self()

    spawn(fn ->
      case SourceMapper.map_stacktrace(error_identity) do
        {:ok, %{"mappings" => mappings, "sources" => sources}} ->
          send(view_pid, %{mappings: mappings, sources: sources})

        _ ->
          nil
      end
    end)

    {:noreply, socket}
  end

  def render_stacktrace_navigation(mappings, current_line, error_identity_message) do
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
        line_num_content = String.pad_leading("#{line["line"]}", max_line_num_len, " ")
        line_num = content_tag(:span, line_num_content, class: "text-slate-400")
        left = content_tag(:span, [line_num, left_half], class: "border-r-2 border-red-300 py-1")
        right_half = String.slice(formatted_line, line["column"], String.length(formatted_line))
        source = content_tag(:span, " #{Path.basename(line["source"])}", class: "text-slate-400")
        right = content_tag(:span, [right_half, source], class: "py-1")

        content_tag(:div, [left, right],
          class:
            "group w-full hover:bg-indigo-100 cursor-pointer whitespace-nowrap pl-2 #{if(current_line == i, do: " bg-indigo-100", else: "")}",
          "phx-click": "set_line_context",
          "phx-value-line": i
        )
      end

    message =
      content_tag(:div, error_identity_message,
        class: "block group w-full text-xs mb-1 pl-2 text-rose-500"
      )

    code = content_tag(:code, [message | lines])
    content_tag(:pre, code, class: "code-snippet")
  end

  def render_line_source_context(_, _, _, nil), do: nil

  def render_line_source_context(mappings, current_line, error_identity_message, sources) do
    current_line_map = Enum.at(mappings, current_line)
    source_file_name = current_line_map["source"]
    source = get_stack_context(mappings, current_line, sources)

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
        line_num_content = String.pad_leading("#{i + 1} ", max_line_num_len, " ")
        line_num = content_tag(:span, line_num_content, class: "text-slate-400 select-none")

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

  def get_stack_context(mappings, current_line, sources) do
    map = Enum.at(mappings, current_line)

    sources[map["source"]]
    |> String.split(~r/\n/)
    |> Enum.with_index()
    |> Enum.slice(map["line"] - 4, 7)
  end

  @impl true
  def handle_info(opts, socket) do
    {:noreply, assign(socket, opts)}
  end

  @impl true
  def handle_event("set_stacktrace_type", %{"type" => value}, socket)
      when value in @stacktrace_types do
    {:noreply, assign(socket, :stacktrace_type, value)}
  end

  @impl true
  def handle_event("set_line_context", %{"line" => line}, socket) do
    {line, ""} = Integer.parse(line)
    socket = assign(socket, current_line: line)
    {:noreply, socket}
  end
end
