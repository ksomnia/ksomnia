defmodule KsomniaWeb.SidebarComponent do
  use KsomniaWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="sidebar-component"
      class="flex-1 flex flex-col min-h-0 border-r border-gray-200 shadow-md bg-gray-50"
    >
      <div class="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
        <.link navigate={~p"/teams"}>
          <div class="flex items-center flex-shrink-0 px-4">
            <h2 class="h-8 w-auto text-2xl font-semibold text-indigo-500">Ksomnia</h2>
          </div>
        </.link>
        <nav class="flex-1 space-y-1 mt-5" aria-label="Sidebar">
          <%= for team <- @user_apps_grouped do %>
            <div class="flex w-full justify-between text-xs px-5 py-1 uppercase font-semibold text-slate-400">
              <.link
                navigate={~p"/t/#{team.id}/apps"}
                class={"#{if @team && team.id == @team.id, do: "text-indigo-400", else: ""} hover:text-indigo-500"}
              >
                <%= team.name %>
              </.link>
              <Heroicons.plus_circle
                class="w-4 h-4 text-slate-400 hover:text-slate-500 cursor-pointer"
                phx-target="#sidebar-component"
                phx-click={
                  JS.push("open-new-app-modal",
                    value: %{team_id: team.id},
                    target: "#sidebar-component"
                  )
                  |> show_modal("new-app-modal")
                }
              />
            </div>
            <%= for app <- team.apps do %>
              <.link
                navigate={~p"/apps/#{app.id}/"}
                class={"#{
                  if @__current_app__ == app.id,
                    do: "bg-indigo-50 border-indigo-600 text-indigo-600 border-l-4",
                    else: "border-l-4 border-slate-50"
                  } text-slate-600 font-medium text-sm px-4 py-2 hover:bg-indigo-50 cursor-pointer block"}
              >
                <%= app.name %>
              </.link>
            <% end %>
          <% end %>
        </nav>
      </div>
      <div class="flex-shrink-0 flex border-t border-gray-200 p-4">
        <.link navigate={~p"/account/profile"} class="flex-shrink-0 w-full group block">
          <div class="flex items-center">
            <div>
              <div class={"relative inline-block h-9 w-9 rounded-full bg-gradient-to-r #{KsomniaWeb.LiveHelpers.generate_gradient(@current_user.username)} text-white flex justify-center items-center font-bold"}>
                <%= KsomniaWeb.LiveHelpers.user_avatar(@current_user) %>
              </div>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-gray-700 group-hover:text-gray-900">
                <%= @current_user.username %>
              </p>
              <p class="text-xs font-medium text-gray-500 group-hover:text-gray-700">View profile</p>
            </div>
          </div>
        </.link>
      </div>
      <.live_component
        module={KsomniaWeb.TeamLive.AppFormComponent}
        app={%Ksomnia.App{}}
        return_to="/"
        action={:new_app}
        id={:wrap}
        new_app_team_id={assigns[:new_app_team_id]}
        team={%{}}
      />
    </div>
    """
  end

  @impl true
  def handle_event("open-new-app-modal", %{"team_id" => team_id}, socket) do
    {:noreply, assign(socket, :new_app_team_id, team_id)}
  end
end
