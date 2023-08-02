defmodule KsomniaWeb.ErrorIdentityLive.AIHint do
  use KsomniaWeb, :live_view
  alias Ksomnia.Repo
  alias Ksomnia.SourceMapper
  alias Ksomnia.AIHint.Prompt
  alias Ksomnia.AIHint.AIHintService
  alias Ksomnia.Schemas.SourceMapper.Mapping
  alias Ksomnia.Queries.ErrorIdentityQueries
  alias KsomniaWeb.AsyncChain

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:mappings, [])
      |> assign(:sources, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    error_identity = ErrorIdentityQueries.get_by_id(id)
    error_identity = Repo.preload(error_identity, app: :team)
    app = error_identity.app
    team = error_identity.app.team

    socket =
      socket
      |> assign(:page_title, error_identity.message)
      |> assign(:error_identity, error_identity)
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:__current_app__, app.id)
      |> assign(:ai_hint, nil)
      |> assign(:prompt, Prompt.build(error_identity))
      |> AsyncChain.start(__MODULE__, [:set_source_map, :set_ai_hint])

    {:noreply, socket}
  end

  def set_source_map(socket) do
    case SourceMapper.map_stacktrace(socket.assigns.error_identity) do
      {:ok, %{"mappings" => mappings, "sources" => sources}} ->
        mappings = Enum.map(mappings, &Mapping.new(&1))

        prompt =
          Prompt.build_for_source_map(
            socket.assigns.error_identity,
            mappings,
            sources
          )

        {:ok, %{mappings: mappings, sources: sources, prompt: prompt}}

      _ ->
        nil
    end
  end

  def set_ai_hint(socket) do
    error_identity = socket.assigns.error_identity
    prompt = socket.assigns.prompt

    case AIHintService.get_or_create_hint_for_prompt(error_identity, prompt) do
      {:ok, ai_hint} ->
        {:ok, %{ai_hint: ai_hint}}

      _ ->
        {:ok, %{ai_reply_error: "Error getting the hint"}}
    end
  end

  @impl true
  def handle_info(opts, socket) do
    {:noreply, assign(socket, opts)}
  end
end
