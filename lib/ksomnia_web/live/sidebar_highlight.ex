defmodule KsomniaWeb.Live.SidebarHighlight do
  def on_mount([set_section: section_name], _params, _session, socket) do
    {:cont, Phoenix.LiveView.assign(socket, :__section__, section_name)}
  end
end
