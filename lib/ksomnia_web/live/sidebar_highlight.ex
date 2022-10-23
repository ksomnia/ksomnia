defmodule KsomniaWeb.Live.SidebarHighlight do
  def on_mount(%{section: section_name} = opts, _params, _session, socket) do
    {:cont,
     socket
     |> Phoenix.LiveView.assign(:__section__, section_name)
     |> Phoenix.LiveView.assign(:__current_app__, opts[:current_app_id])}
  end
end
