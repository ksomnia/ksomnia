defmodule KsomniaWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers
  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.app_index_path(@socket, :index)}>
        <.live_component
          module={KsomniaWeb.AppLive.FormComponent}
          id={@app.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.app_index_path(@socket, :index)}
          app: @app
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  def user_apps(assigns) do
    # {:ok, assign_new(socket, :current_user, fn -> Accounts.get_user!(user_id) end)}

    dbg(assigns)
    dbg(assigns |> Map.keys())
    dbg(assigns.current_user)

    ~H"""
    <div>user apps</div>
    """
  end
end
