defmodule KsomniaWeb.AppLive.SettingsNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex ml-8 mb-2">
      <.link
        navigate={~p"/apps/#{@app.id}/settings"}
        class={[
          "#{if @settings_section == :settings, do: "bg-indigo-100", else: "bg-transparent"}",
          "p-2 hover:bg-indigo-100 text-indigo-700 font-medium rounded-md cursor-pointer mr-2"
        ]}
      >
        Application
      </.link>
      <.link
        navigate={~p"/apps/#{@app.id}/settings/tokens"}
        class={[
          "#{if @settings_section == :tokens, do: "bg-indigo-100", else: "bg-transparent"}",
          "p-2 hover:bg-indigo-100 text-indigo-700 font-medium rounded-md cursor-pointer mr-2"
        ]}
      >
        Tokens
      </.link>
    </div>
    """
  end

  def on_mount([set_section: section_name], _params, _session, socket) do
    {:cont, assign(socket, :__settings_section__, section_name)}
  end
end
