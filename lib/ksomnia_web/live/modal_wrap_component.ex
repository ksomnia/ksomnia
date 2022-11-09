defmodule KsomniaWeb.Live.ModalWrapComponent do
  use KsomniaWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
      <div id="modal-wrap-component">
        <%= if @open_modal do %>
          <.modal>
            <.live_component
              module={KsomniaWeb.TeamLive.AppFormComponent}
              id={:new}
              action={:new_app}
              team_id={@team.id}
              app={%Ksomnia.App{}}
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

    {:ok, socket}
  end

  @impl true
  def handle_event("open-modal", _opts, socket) do
    {:noreply, assign(socket, :open_modal, true)}
  end
end
