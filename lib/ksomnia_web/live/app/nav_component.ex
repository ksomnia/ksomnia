defmodule KsomniaWeb.AppLive.NavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <nav class="px-7 py-4 isolate flex divide-x divide-gray-200 rounded-lg">
        <.link
          navigate={~p"/apps/#{@app.id}"}
          class="text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
        >
          <Heroicons.bug_ant class="w-4 h-4 inline-block" />
          <span>Errors</span>
          <span aria-hidden="true" class={"#{if @nav_section == :show, do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5", else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"}></span>
        </.link>

        <.link
          class="text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
          navigate={~p"/apps/#{@app.id}/settings"}
        >
          <Heroicons.cog class="w-4 h-4 inline-block" />
          <span>Settings</span>
          <span aria-hidden="true" class={"#{if @nav_section == :settings, do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5", else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"}></span>
        </.link>

        <.link
          class="text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
          navigate={~p"/apps/#{@app.id}/source_maps"}
        >
          <Heroicons.globe_alt class="w-4 h-4 inline-block" />
          <span>Source Maps</span>
          <span aria-hidden="true" class={"#{if @nav_section == :source_maps, do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5", else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"}></span>
        </.link>
      </nav>
    </div>
    """
  end

  def on_mount([set_section: section_name], _params, _session, socket) do
    {:cont, assign(socket, :__nav_section__, section_name)}
  end
end
