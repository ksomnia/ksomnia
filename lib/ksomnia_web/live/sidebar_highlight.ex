defmodule KsomniaWeb.Live.SidebarHighlight do
  use Phoenix.LiveComponent

  def on_mount(%{section: section_name} = opts, _params, _session, socket) do
    {:cont,
     socket
     |> assign(:__section__, section_name)
     |> assign(:__current_app__, opts[:current_app_id])}
  end

  def render(id), do: id
end
