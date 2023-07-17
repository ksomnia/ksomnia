defmodule KsomniaWeb.CoreComponents.ItemMenu do
  use Phoenix.Component

  @doc """
  Render an item menu

  ## Examples

      <.item_menu id="team-menu" items={@items} link={fn item -> ~p"/items/{item.id}" end}>
        <:item_row :let={item}>
          <%= item.title %>
        </:item_row>
      </.item_menu>
  """
  attr(:id, :string, required: true)
  attr(:items, :list)
  attr(:link, :any)

  slot :item_row, required: true do
    attr(:item, :any)
  end

  def item_menu(assigns) do
    ~H"""
    <ul role="list" class="mt-4 divide-y border-gray-200 border-t border-b dark:border-gray-600">
      <.link
        :for={item <- @items}
        :if={assigns[:link]}
        navigate={@link.(item)}
        class="flex items-center justify-between space-x-3 py-4 px-4 hover:bg-gray-50 cursor-pointer dark:hover:bg-indigo-700"
      >
        <%= render_slot(@item_row, item) %>
      </.link>
    </ul>
    """
  end
end
