defmodule KsomniaWeb.CoreComponents.Pagination do
  use Phoenix.Component

  @doc """
  Renders a pagination.

  ## Examples

      <.pagination
        current_page={1}
        current_page_size={2}
        page_size={10}
        entry_count={42}
        surrounding_size={2}
        total_pages={3}
        link={& ~p"/apps/\#{@app.id}?page=\#{&1}"}
      />
  """
  attr(:current_page, :integer, required: true)
  attr(:current_page_size, :integer, required: true)
  attr(:page_size, :integer, required: true)
  attr(:entry_count, :integer, required: true)
  attr(:surrounding_size, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:link, :any, required: true)

  def pagination(assigns) do
    ~H"""
    <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
      <div>
        <p class="text-sm text-gray-700">
          Showing
          <span class="font-medium">
            <%= (@current_page - 1) * @page_size %>
          </span>
          to
          <span class="font-medium">
            <%= (@current_page - 1) * @page_size + @current_page_size %>
          </span>
          of <span class="font-medium"><%= @entry_count %></span>
          results
        </p>
      </div>
      <div>
        <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
          <.link
            :if={@current_page != 1}
            navigate={@link.(@current_page - 1)}
            class="relative inline-flex items-center rounded-l-md border border-gray-300 bg-white px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20"
          >
            <span class="sr-only">Previous</span>
            <Heroicons.chevron_left class="w-5 h-5 text-slate-400 hover:text-slate-500 cursor-pointer" />
          </.link>
          <.link
            navigate={@link.(1)}
            class={[
              (if @current_page == 1,
                do: "z-10 bg-indigo-50 border-indigo-500 text-indigo-600",
                else: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50"),
                "inline-flex items-center border px-4 py-2 text-sm font-medium focus:z-20"
              ]
            }>
            1
          </.link>
          <span
            :if={@current_page > @surrounding_size + 2}
            class="relative inline-flex items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700"
          >
            ...
          </span>
          <% page_start = Enum.max([2, @current_page - @surrounding_size]) %>
          <% page_end = @current_page + @surrounding_size %>
          <%= for page <- page_start..page_end do %>
            <.link
              :if={page < @total_pages}
              navigate={@link.(page)}
              class={"#{if @current_page == page, do: "z-10 bg-indigo-50 border-indigo-500 text-indigo-600", else: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50"} inline-flex items-center border px-4 py-2 text-sm font-medium focus:z-20"}
            >
              <%= page %>
            </.link>
          <% end %>
          <span
            :if={@current_page < @total_pages - (@surrounding_size + 1)}
            class="relative inline-flex items-center border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700"
          >
            ...
          </span>
          <.link
            :if={@total_pages > 1}
            navigate={@link.(@total_pages)}
            class={"#{
            if @current_page == @total_pages,
              do: "z-10 bg-indigo-50 border-indigo-500 text-indigo-600",
              else: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50"
            } inline-flex items-center border px-4 py-2 text-sm font-medium focus:z-20"}
          >
            <%= @total_pages %>
          </.link>
          <.link
            :if={@current_page != @total_pages}
            navigate={@link.(@current_page + 1)}
            class="relative inline-flex items-center rounded-r-md border border-gray-300 bg-white px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-20"
          >
            <span class="sr-only">Next</span>
            <Heroicons.chevron_right class="w-5 h-5 text-slate-400 hover:text-slate-500 cursor-pointer" />
          </.link>
        </nav>
      </div>
    </div>
    """
  end
end
