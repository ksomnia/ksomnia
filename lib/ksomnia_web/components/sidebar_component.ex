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
                class={
                  "#{if team && team.id == (assigns[:current_team] && assigns[:current_team].id),
                  do: "text-indigo-400", else: ""} hover:text-indigo-500"
                }
              >
                <%= team.name %>
              </.link>
              <Heroicons.plus_circle
                class="w-4 h-4 text-slate-400 hover:text-slate-500 cursor-pointer"
                phx-target="#sidebar-component"
                phx-value-team-id={team.id}
                phx-click={
                  JS.push("set-new-app-modal-data")
                  |> show_modal("new-app-modal")
                }
              />
            </div>
            <.link
              :for={app <- team.apps}
              navigate={~p"/apps/#{app.id}/"}
              class={"#{
                if (@current_app && @current_app.id) == app.id,
                  do: "bg-indigo-50 border-indigo-600 text-indigo-600 border-l-4",
                  else: "border-l-4 border-slate-50"
                } text-slate-600 font-medium text-sm px-4 py-2 hover:bg-indigo-50 cursor-pointer block"}
            >
              <div class="flex">
                <.avatar_sm name={app.name} src={app.avatar_original_path} />
                <span>
                  <%= app.name %>
                </span>
              </div>
            </.link>
          <% end %>
        </nav>
      </div>
      <div class="flex-shrink-0 flex border-t border-gray-200 p-4">
        <.link navigate={~p"/account/profile"} class="flex-shrink-0 w-full group block">
          <div class="flex items-center">
            <div>
              <.avatar
                name={@current_user.username}
                src={@current_user.avatar_resized_paths["160x160"]}
                class="h-9 w-9"
              />
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
    </div>
    """
  end

  @impl true
  def handle_event("set-new-app-modal-data", %{"team-id" => team_id}, socket) do
    send_update(KsomniaWeb.TeamLive.AppFormComponent, id: :new_app_modal, new_app_team_id: team_id)
    {:noreply, socket}
  end
end
