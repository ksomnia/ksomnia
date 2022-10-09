defmodule KsomniaWeb.Live.PlusComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <svg phx-click={"open-modal"} phx-target="#modal-wrap-component" class="w-4 h-4 text-slate-400 hover:text-slate-500 cursor-pointer" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
    """
  end

  @impl true
  def handle_event("open-modal", opts, socket) do
    dbg(opts)
    {:noreply, assign(socket, :open_modal, true)}
  end

  @impl true
  def update(assigns, socket) do
    dbg(:update)

    socket =
      socket
      |> assign(socket, assigns)
      # |> assign_changeset()

    {:ok, socket}
  end
end
