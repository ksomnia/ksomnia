defmodule KsomniaWeb.TeamLive.MembersNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex ml-8 mt-5">
      <%= live_patch [
        to: Routes.team_members_path(@socket, :members, @team),
        class: "#{if @nav_section == :members, do: "bg-indigo-200", else: "bg-transparent"} p-2 hover:bg-indigo-200 text-indigo-900 font-medium rounded-md cursor-pointer mr-2"
      ] do %>
        Members
      <% end %>
      <%= live_patch [
        to: Routes.team_invites_path(@socket, :invites, @team),
        class: "#{if @nav_section == :invites, do: "bg-indigo-200", else: "bg-transparent"} p-2 hover:bg-indigo-200 text-indigo-900 font-medium rounded-md cursor-pointer mr-2"
      ] do %>
        Pending invites
      <% end %>
    </div>
    """
  end
end
