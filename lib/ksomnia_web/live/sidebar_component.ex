defmodule KsomniaWeb.Live.SidebarComponent do
  use KsomniaWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col min-h-0 border-r border-gray-200 shadow-md bg-gray-50">
      <div class="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
        <a href="/">
          <div class="flex items-center flex-shrink-0 px-4">
            <h2 class="h-8 w-auto text-2xl font-semibold text-indigo-500">Ksomnia</h2>
          </div>
        </a>
        <nav class="flex-1 space-y-1 mt-5" aria-label="Sidebar">
          <%= for team <- @user_apps_grouped do %>
            <div class="flex w-full justify-between text-xs px-5 py-1 uppercase font-semibold text-slate-400">
              <%= live_redirect "#{team.name}", [to: Routes.team_settings_path(@socket, :settings, team), class: "#{if @team && team.id == @team.id, do: "text-indigo-400", else: ""} hover:text-indigo-500"] %>
              <svg phx-click={"open-modal"} phx-target="#modal-wrap-component" class="w-4 h-4 text-slate-400 hover:text-slate-500 cursor-pointer" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>

            <%= for app <- team.apps do %>
              <%= live_redirect app.name, [
                to: Routes.app_show_path(@socket, :show, app),
                class: "#{if @__current_app__ == app.id, do: "bg-indigo-50 border-indigo-600 text-indigo-600 border-l-4", else: "border-l-4 border-slate-50"} text-slate-600 font-medium text-sm px-4 py-2 hover:bg-indigo-50 cursor-pointer block"
              ] %>
            <% end %>
          <% end %>
        </nav>
      </div>
      <div class="flex-shrink-0 flex border-t border-gray-200 p-4">
        <%= live_redirect [
          to: Routes.account_profile_path(@socket, :profile),
          class: "flex-shrink-0 w-full group block"
        ] do %>
          <div class="flex items-center">
            <div>
              <div class={"relative inline-block h-9 w-9 rounded-full bg-gradient-to-r #{generate_gradient(@current_user.username)} text-white flex justify-center items-center font-bold"}>
                <%= user_avatar(@current_user) %>
              </div>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-gray-700 group-hover:text-gray-900"><%= @current_user.username %></p>
              <p class="text-xs font-medium text-gray-500 group-hover:text-gray-700">View profile</p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("open-modal", _opts, socket) do
    {:noreply, assign(socket, :open_modal, true)}
  end
end
