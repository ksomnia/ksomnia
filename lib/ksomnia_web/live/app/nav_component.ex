defmodule KsomniaWeb.AppLive.NavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex px-7 pt-4">
      <.avatar_sm name={@app.name} src={@app.avatar_original_path} />
      <span class="font-bold text-slate-600 dark:text-slate-400">
        <%= @app.name %>
      </span>
    </div>

    <.top_nav_menu id="top_nav_menu">
      <:item link={~p"/apps/#{@app.id}"} label="Errors" active={@nav_section == :show}>
        <Heroicons.bug_ant class="w-4 h-4 inline-block" />
      </:item>
      <:item
        link={~p"/apps/#{@app.id}/settings/tokens"}
        label="Tokens"
        active={@nav_section == :tokens}
      >
        <Heroicons.key class="w-4 h-4 inline-block" />
      </:item>
      <:item
        link={~p"/apps/#{@app.id}/source_maps"}
        label="Source Maps"
        active={@nav_section == :source_maps}
      >
        <Heroicons.globe_alt class="w-4 h-4 inline-block" />
      </:item>
      <:item link={~p"/apps/#{@app.id}/settings"} label="Setting" active={@nav_section == :settings}>
        <Heroicons.cog class="w-4 h-4 inline-block" />
      </:item>
    </.top_nav_menu>
    """
  end

  def on_mount([set_section: section_name], _params, _session, socket) do
    {:cont, assign(socket, :__nav_section__, section_name)}
  end
end
