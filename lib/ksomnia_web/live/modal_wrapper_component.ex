defmodule KsomniaWeb.Live.ModalWrapperComponent do
  use KsomniaWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
      <div id="modal-wrapper-component">
        <%= if @open_modal do %>
          <.modal return_to={nil}>
            <%= render_slot(@inner_block) %>
          </.modal>
        <% end %>
      </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:modal_wrapper_state, %{})
      |> assign(socket, socket.assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event("open-modal", opts, socket) do
    modal_wrapper_state = socket.assigns.modal_wrapper_state
    modal_wrapper_state = Map.put(modal_wrapper_state, opts.key, true)
    {:noreply, assign(socket, :modal_wrapper_state, modal_wrapper_state)}
  end

  def handle_event("revoke_invite", %{"invite-id" => invite_id}, socket) do
    # check user role
    {:noreply, assign(socket, :invite_id, invite_id)}
  end
end
