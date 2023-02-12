defmodule KsomniaWeb.TeamLive.MembersNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div class="pl-8 text-left">
        <a
          class="btn-primary inline-flex items-center"
          phx-click={show_modal(%JS{}, "new-invite-modal")}
        >
          <Heroicons.plus class="-ml-1 mr-2 h-5 w-5" /> Invite member
        </a>
      </div>
      <div class="flex ml-8 mt-5">
        <.link
          navigate={~p"/t/#{@current_team.id}/members"}
          class={[
            "#{if @nav_section == :members, do: "bg-indigo-100", else: "bg-transparent"}",
            "p-2 hover:bg-indigo-100 text-indigo-700 font-medium rounded-md cursor-pointer mr-2"
          ]}
        >
          Members
        </.link>
        <.link
          navigate={~p"/t/#{@current_team.id}/members/invites"}
          class={[
            "#{if @nav_section == :invites, do: "bg-indigo-100", else: "bg-transparent"}",
            "p-2 hover:bg-indigo-100 text-indigo-700 font-medium rounded-md cursor-pointer mr-2"
          ]}
        >
          Pending invites
        </.link>
        <.live_component
          module={KsomniaWeb.TeamLive.InviteModalComponent}
          current_team={@current_team}
          current_user={@current_user}
          id={:new_invite}
        />
      </div>
    </div>
    """
  end
end
