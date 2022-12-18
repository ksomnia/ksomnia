defmodule KsomniaWeb.TeamLive.MembersNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div class="pl-8 text-left">
        <a
          class="cursor-pointer inline-flex items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          phx-click={
            %JS{}
            |> show_modal("new-invite-modal")
          }>
          <!-- Heroicon name: mini/plus -->
          <svg class="-ml-1 mr-2 h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z" />
          </svg>
          Invite member
        </a>
      </div>
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
        <.live_component
          module={KsomniaWeb.TeamLive.InviteModalComponent}
          team={@team}
          return_to={"/"}
          id={:new_invite}
        />
      </div>
    </div>
    """
  end
end
