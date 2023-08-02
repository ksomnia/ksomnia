defmodule KsomniaWeb.CoreComponents.Table do
  use Phoenix.Component
  import KsomniaWeb.Gettext

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:row_click, :any, default: nil)
  attr(:rows, :list, required: true)
  attr(:headers, :boolean, default: true)

  slot :col, required: true do
    attr(:label, :string)
    attr(:th_class, :string)
    attr(:td_class, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def table(assigns) do
    ~H"""
    <div id={@id} class="overflow-y-auto divide-y divide-gray-300 px-4 sm:overflow-visible sm:px-0">
      <table class="mt-2 w-[40rem] sm:w-full">
        <thead
          :if={@headers}
          class={[
            "text-left text-[0.8125rem] leading-6",
            "bg-gray-50 text-zinc-500",
            "dark:bg-slate-700 dark:text-slate-300"
          ]}
        >
          <tr>
            <th
              :for={col <- @col}
              class={"py-3.5 pl-4 pr-3 text-left text-sm font-semibold #{col[:th_class]}"}
            >
              <%= col[:label] %>
            </th>
            <th class="p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody class={[
          "divide-y divide-gray-200 font-medium text-sm leading-6",
          "bg-white dark:bg-slate-800 text-zinc-700 dark:text-slate-300"
        ]}>
          <tr :for={row <- @rows} id={"#{@id}-#{Phoenix.Param.to_param(row)}"}>
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["p-0", col[:td_class], @row_click && "hover:cursor-pointer"]}
            >
              <div :if={i == 0}>
                <span class="h-full w-4 top-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class="h-full w-4 top-0 -right-4 group-hover:bg-zinc-50 sm:rounded-r-xl" />
              </div>
              <div class="block py-4 pr-6 pl-3.5">
                <span class={[i == 0 && "font-semibold text-zinc-900 "]}>
                  <%= render_slot(col, row) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="p-0 w-14">
              <div class="py-4 text-right text-sm font-medium">
                <span
                  :for={action <- @action}
                  class="ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, row) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
