defmodule KsomniaWeb.TeamLive.NavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <.top_nav_menu id="top_nav_menu">
      <:item link={~p"/t/#{@team.id}/apps"} label="Apps" active={@nav_section == :apps}>
        <Heroicons.magnifying_glass class="w-4 h-4 inline-block" />
      </:item>
      <:item link={~p"/t/#{@team.id}/members"} label="Members" active={@nav_section == :members}>
        <Heroicons.user_group class="w-4 h-4 inline-block" />
      </:item>
      <:item link={~p"/t/#{@team.id}/settings"} label="Setting" active={@nav_section == :settings}>
        <Heroicons.cog class="w-4 h-4 inline-block" />
      </:item>
    </.top_nav_menu>
    """
  end

  def on_mount([set_section: section_name], _params, _session, socket) do
    {:cont, assign(socket, :__nav_section__, section_name)}
  end
end
