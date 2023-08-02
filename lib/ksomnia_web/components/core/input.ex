defmodule KsomniaWeb.CoreComponents.Input do
  use Phoenix.Component
  import KsomniaWeb.CoreComponents
  import KsomniaWeb.CoreComponents.Avatar

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr(:id, :any)
  attr(:name, :any)
  attr(:label, :string, default: nil)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week placeholder avatar)
  )

  attr(:value, :any)
  attr(:field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}")
  attr(:errors, :list)
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:clear, :any)
  attr(:uploads, :any, doc: "LiveView uploads")
  attr(:placeholder, :string)
  attr(:rest, :global, include: ~w(autocomplete disabled form max maxlength min minlength
                                   pattern placeholder readonly required size step))
  slot(:inner_block)

  def input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn ->
      name = Phoenix.HTML.Form.input_name(f, field)
      if assigns.multiple, do: name <> "[]", else: name
    end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> translate_errors(f.errors || [], field) end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_equals?(assigns.value, "true") end)

    ~H"""
    <label phx-feedback-for={@name} class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id || @name}
        name={@name}
        value="true"
        checked={@checked}
        class="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900"
        {@rest}
      />
      <%= @label %>
    </label>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt}><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          input_border(@errors),
          "block min-h-[6rem] w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      >

    <%= @value %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "avatar"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <span class="mt-2 border border-slate-300 border-1 rounded-full inline-flex dark:border-slate-700">
        <label class={[
          "group relative inline-block border border-8 border-slate-50 dark:border-slate-600",
          "rounded-full overflow-hidden items-center justify-center flex w-24 h-24"
        ]}>
          <% upload = Enum.at(@uploads.avatar.entries, 0) %>
          <.live_file_input
            upload={@uploads.avatar}
            class="opacity-0 absolute top-0 left-0 w-full h-full cursor-pointer"
          />
          <%= cond do %>
            <% upload -> %>
              <figure>
                <.live_img_preview entry={upload} class="w-20 h-20" />
              </figure>
            <% @value -> %>
              <span class="w-20 h-20 ease-in duration-300">
                <img src={@value} class="w-20 h-20" />
              </span>
            <% true -> %>
              <.avatar
                name={@placeholder}
                class="w-20 h-20 text-4xl group-hover:shadow-inner-semidark group-hover:text-slate-500 ease-in duration-300"
              />
          <% end %>
          <div class={[
            "flex items-center absolute text-center h-full capitalize",
            "text-white text-xs font-bold cursor-pointer",
            "group-hover:shadow-inner-dark group-hover:opacity-100 opacity-0 ease-in duration-300"
          ]}>
            <span class="text-xs">CHANGE AVATAR</span>
          </div>
        </label>
      </span>
    </div>
    """
  end

  def input(%{type: "search"} = assigns) do
    ~H"""
    <div class="px-1">
      <.label for={@id} class="sr-only"><%= @label %></.label>
      <div class="relative mt-1 rounded-md shadow-sm">
        <div
          class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
          aria-hidden="true"
        >
          <Heroicons.magnifying_glass class="mr-3 h-4 w-4 text-gray-400" />
        </div>
        <input
          type="text"
          name={@id}
          id={@id}
          value={@value}
          placeholder={@label}
          class={[
            "search-input block w-full rounded-md pl-9 sm:text-sm",
            "border-gray-300 focus:border-indigo-500 focus:ring-indigo-500",
            "dark:bg-slate-800",
            "dark:border-slate-600"
          ]}
        />
        <div
          class="z-10 absolute inset-y-0 right-0 flex items-center pl-3 cursor-pointer"
          phx-click={@clear}
          aria-hidden="true"
        >
          <Heroicons.x_circle class="mr-3 h-4 w-4 text-gray-400 hover:text-gray-500 cursor-pointer" />
        </div>
      </div>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id} class="dark:text-indigo-400"><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          input_border(@errors),
          "block w-full rounded-md shadow-sm border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
          "dark:text-slate-400 dark:bg-slate-700 dark:phx-no-feedback:border-slate-700 dark:phx-no-feedback:focus:border-slate-500 dark:phx-no-feedback:focus:ring-indigo-800/5",
          "dark:bg-indigo-800"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp input_border([] = _errors),
    do:
      "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5 dark:focus:border-indigo-300 dark:border-indigo-400 "

  defp input_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end
end
