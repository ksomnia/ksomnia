defmodule KsomniaWeb.CoreComponents.TopNavMenu do
  use Phoenix.Component

  @doc """
  Render a top navigation menu

  ## Examples

      <.top_nav_menu id="top_nav_menu">
        <:item link={~p"/settings"} label="Settings" active={true}>
          <Heroicons.cog class="w-4 h-4 inline-block" />
        </:item>
      </.top_nav_menu>
  """
  attr(:id, :string, required: true)

  slot :item, required: true do
    attr(:link, :any)
    attr(:active, :boolean)
    attr(:label, :string)
  end

  def top_nav_menu(assigns) do
    ~H"""
    <div>
      <nav class="px-7 py-4 isolate flex divide-x rounded-lg">
        <.link
          :for={item <- @item}
          navigate={item[:link]}
          class="dark:border-slate-600 text-slate-500 hover:text-slate-700 dark:hover:text-slate-400 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 dark:bg-slate-700 dark:hover:bg-slate-600 focus:z-10"
        >
          <%= render_slot(item) %>
          <span><%= item[:label] %></span>
          <span
            aria-hidden="true"
            class={[
              "#{if item[:active],
                do: "bg-indigo-500 dark:bg-indigo-400 absolute inset-x-0 bottom-0 h-0.5",
                else: "bg-transparent dark:bg-slate-700 absolute inset-x-0 bottom-0 h-0.5"}"
            ]}
          >
          </span>
        </.link>
      </nav>
    </div>
    """
  end
end
