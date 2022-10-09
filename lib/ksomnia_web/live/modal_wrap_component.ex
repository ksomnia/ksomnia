defmodule KsomniaWeb.Live.ModalWrapComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
      <div id="modal-wrap-component">
        <%= "wrap #{@open_modal}" %>
        <%= if @open_modal do %>
          <.modal return_to={nil}>
            <.live_component
              module={KsomniaWeb.TeamLive.AppFormComponent}
              id={:new}
              action={:new_app}
              team_id={@team.id}
              app={%Ksomnia.App{}}
              return_to={nil}
            />
          </.modal>
        <% end %>
      </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:open_modal, false)
      |> assign(socket, socket.assigns)

    dbg(:mount)
    dbg(Map.keys(socket.assigns))

    {:ok, socket}
  end

  # @impl true
  # def update(assigns, socket) do
  #   socket =
  #     socket
  #     |> assign(socket, assigns)

  #   dbg(Map.keys(socket.assigns))

  #   {:ok, socket}
  # end

  @impl true
  def handle_event("open-modal", opts, socket) do
    dbg(opts)
    {:noreply, assign(socket, :open_modal, true)}
  end
end
