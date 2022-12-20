defmodule KsomniaWeb.BreadcrumbComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <% [root | rest] = @links %>
    <div class="px-4 py-4 sm:flex sm:items-center sm:justify-between sm:px-6 lg:px-8">
      <div class="flex-1 min-w-0">
        <div class="max-w-7xl">
          <nav class="flex" aria-label="Breadcrumb">
            <ol role="list" class="flex items-center space-x-4">
              <li>
                <div>
                  <.link
                    navigate={root.url}
                    class="text-sm font-medium text-gray-500 hover:text-gray-700"
                  >
                    <%= root.title %>
                  </.link>
                </div>
              </li>
              <%= for link <- rest do %>
                <li>
                  <div class="flex items-center">
                    <Heroicons.chevron_right class="flex-shrink-0 h-5 w-5 text-gray-400" />
                    <.link
                      navigate={link.url}
                      class="ml-4 text-sm font-medium text-gray-500 hover:text-gray-700"
                    >
                      <%= link.title %>
                    </.link>
                  </div>
                </li>
              <% end %>
            </ol>
          </nav>
        </div>
      </div>
    </div>
    """
  end
end
