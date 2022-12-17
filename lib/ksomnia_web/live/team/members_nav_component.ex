defmodule KsomniaWeb.TeamLive.MembersNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex ml-8 mt-5">
      <.link
        navigate={~p"/t/#{@team.id}/members"}
        class={"#{if @nav_section == :members, do: "bg-indigo-200", else: "bg-transparent"} p-2 hover:bg-indigo-200 text-indigo-900 font-medium rounded-md cursor-pointer mr-2"}>
        Members
      </.link>
      <.link
        navigate={~p"/t/#{@team.id}/members/invites"}
        class={"#{if @nav_section == :invites, do: "bg-indigo-200", else: "bg-transparent"} p-2 hover:bg-indigo-200 text-indigo-900 font-medium rounded-md cursor-pointer mr-2"}>
        Pending invites
      </.link>
    </div>
    """
  end
end
