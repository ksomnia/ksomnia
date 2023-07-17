defmodule KsomniaWeb.CoreComponents.SubNavMenu do
  use Phoenix.Component

  def sub_nav_menu(assigns) do
    ~H"""
    <div class="flex mt-5 mb-5">
      <.link
        :for={item <- @item}
        navigate={item[:link]}
        class={[
          "#{if item[:active], do: "bg-indigo-100 dark:text-indigo-300 dark:border-indigo-300", else: "bg-slate-100 dark:text-indigo-400 dark:border-slate-600"}",
          "p-2 hover:bg-indigo-100 text-indigo-700 font-medium rounded-md cursor-pointer mr-2 dark:bg-transparent dark:hover:bg-transparent dark:border dark:hover:text-indigo-300 dark:hover:border-indigo-300"
        ]}
      >
        <%= render_slot(item) %>
      </.link>
    </div>
    """
  end
end
