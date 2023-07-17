defmodule KsomniaWeb.ErrorIdentityLive.AIHint do
  use KsomniaWeb, :live_view
  alias Ksomnia.Repo
  alias Ksomnia.SourceMapper
  alias Ksomnia.AIHint.Prompt

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:stacktrace_type, "source_map")
      |> assign(:mappings, [])
      |> assign(:sources, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    error_identity = Ksomnia.Queries.ErrorIdentityQueries.get_by_id(id)
    error_identity = Repo.preload(error_identity, app: :team)
    app = error_identity.app
    team = error_identity.app.team

    ai_hint = """
    Hint sample:

    Example:
    ```javascript
    const errorSample = (x) => {
      if (x.hasOwnProperty('missing-key')) {
        return x['missing-key'](x);
      }
      // Handle the case when the 'missing-key' property does not exist
      // e.g., throw an error, return a default value, or handle the case accordingly
    }
    ```
    """

    socket =
      socket
      |> assign(:page_title, error_identity.message)
      |> assign(:error_identity, error_identity)
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:__current_app__, app.id)
      |> assign(:ai_hint, ai_hint)
      |> assign(:prompt, Ksomnia.AIHint.Prompt.build(error_identity))
      |> assign(:ai_reply, nil)

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

  @impl true
  def handle_info(opts, socket) do
    socket =
      socket
      |> assign(opts)
      |> maybe_set_prompt(opts)

    {:noreply, socket}
  end

  def maybe_set_prompt(socket, opts) do
    mappings = Enum.map(opts.mappings, &Ksomnia.Schemas.SourceMapper.Mapping.new(&1))

    if opts[:mappings] && !Enum.empty?(opts[:mappings]) do
      prompt =
        Prompt.build_for_source_map(
          socket.assigns.error_identity,
          mappings,
          opts[:sources]
        )

      socket
      |> assign(:prompt, prompt)
    else
      socket
    end
  end

  def maybe_set_ai_reply(socket, opts) do
    if prompt = opts[:prompt] do
      ai_reply = Ksomnia.Queries.AIHintQueries.latest_for_prompt(prompt)

      socket
      |> assign(:ai_reply, ai_reply)
    else
      socket
    end
  end
end
