defmodule KsomniaWeb.Live.TopNavbarComponent do
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
                  <%= live_redirect [to: root.url, class: "text-sm font-medium text-gray-500 hover:text-gray-700"] do %>
                    <%= root.title %>
                  <% end %>
                </div>
              </li>
              <%= for link <- rest do %>
                <li>
                  <div class="flex items-center">
                    <svg class="flex-shrink-0 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                    </svg>
                    <%= live_redirect [to: link.url, class: "ml-4 text-sm font-medium text-gray-500 hover:text-gray-700"] do %>
                      <%= link.title %>
                    <% end %>
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
