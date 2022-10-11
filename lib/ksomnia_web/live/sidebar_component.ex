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
          <%= live_redirect to: Routes.team_index_path(@socket, :index), class: "#{if false, do: "bg-slate-50 border-indigo-50 text-slate-600 border-l-4", else: "border-transparent text-gray-600 hover:bg-gray-50 hover:text-gray-900"} group flex items-center px-3 py-2 text-sm font-medium border-l-4 relative" do %>
            <svg xmlns="http://www.w3.org/2000/svg" class="absolute ml-1 flex-shrink-0 h-5 w-5 opacity-50" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
            </svg>
            <input class="pl-7 p-1 px-2 border-slate-200 border rounded-none bg-slate-50 w-full border-t-0 border-l-0 border-r-0" placeholder="Search ..." />
          <% end %>

          <%= for team <- @user_apps_grouped do %>
            <div class="flex justify-between text-xs px-5 py-1 uppercase font-semibold text-slate-400">
              <a><%= team.name %> Apps</a>
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
      <%= if assigns[:team] do %>
        <div class="px-4 py-2 text-slate-500 border-t border-gray-200 cursor-pointer">
          <span class="font-medium text-sm">
          <%= @team.name %>
          </span>
        </div>
      <% end %>
      <div class="flex-shrink-0 flex border-t border-gray-200 p-4">
        <%= live_redirect [
          to: Routes.account_profile_path(@socket, :profile),
          class: "flex-shrink-0 w-full group block"
        ] do %>
          <div class="flex items-center">
            <div>
              <div class="relative inline-block h-9 w-9 rounded-full bg-gradient-to-r from-indigo-300 to-blue-300 text-white flex justify-center items-center font-bold">
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
