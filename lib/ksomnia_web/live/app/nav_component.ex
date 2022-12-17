defmodule KsomniaWeb.AppLive.NavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <nav class="px-7 py-4 isolate flex divide-x divide-gray-200 rounded-lg">
        <%= live_redirect [
          to: ~p"/apps/#{@app.id}",
          class: "text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
        ] do %>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 inline-block">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
          </svg>
          <span>Errors</span>
          <span aria-hidden="true" class={"#{if @nav_section == :show, do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5", else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"}></span>
        <% end %>

        <%= live_redirect [
          to: ~p"/apps/#{@app.id}/settings",
          class: "text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
        ] do %>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 inline-block">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z" />
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <span>Settings</span>
          <span aria-hidden="true" class={"#{if @nav_section == :settings, do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5", else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"}></span>
        <% end %>

        <%= live_redirect [
          to: ~p"/apps/#{@app.id}/source_maps",
          class: "text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
        ] do %>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 inline-block">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 21a9.004 9.004 0 008.716-6.747M12 21a9.004 9.004 0 01-8.716-6.747M12 21c2.485 0 4.5-4.03 4.5-9S14.485 3 12 3m0 18c-2.485 0-4.5-4.03-4.5-9S9.515 3 12 3m0 0a8.997 8.997 0 017.843 4.582M12 3a8.997 8.997 0 00-7.843 4.582m15.686 0A11.953 11.953 0 0112 10.5c-2.998 0-5.74-1.1-7.843-2.918m15.686 0A8.959 8.959 0 0121 12c0 .778-.099 1.533-.284 2.253m0 0A17.919 17.919 0 0112 16.5c-3.162 0-6.133-.815-8.716-2.247m0 0A9.015 9.015 0 013 12c0-1.605.42-3.113 1.157-4.418" />
          </svg>
          <span>Source Maps</span>
          <span aria-hidden="true" class={"#{if @nav_section == :source_maps, do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5", else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"}></span>
        <% end %>
      </nav>
    </div>
    """
  end

  def on_mount([set_section: section_name], _params, _session, socket) do
    {:cont, assign(socket, :__nav_section__, section_name)}
  end
end
