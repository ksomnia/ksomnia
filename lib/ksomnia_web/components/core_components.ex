defmodule KsomniaWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias KsomniaWeb.LiveHelpers
  import KsomniaWeb.Gettext

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title
  slot :subtitle
  slot :confirm
  slot :cancel

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} class="relative z-50 hidden">
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-6 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={hide_modal(@on_cancel, @id)}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <Heroicons.x_mark solid class="h-5 w-5 stroke-current" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                    <%= render_slot(@title) %>
                  </h1>
                  <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>
                <%= render_slot(@inner_block) %>
                <div :if={@confirm != [] or @cancel != []} class="mb-4 mt-4 flex items-center gap-5">
                  <.button
                    :for={confirm <- @confirm}
                    id={"#{@id}-confirm"}
                    phx-click={@on_confirm}
                    phx-disable-with
                    class="py-2 px-3"
                  >
                    <%= render_slot(confirm) %>
                  </.button>
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                  >
                    <%= render_slot(cancel) %>
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("#flash")}
      role="alert"
      class={[
        "fixed hidden top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 p-3 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
        <Heroicons.information_circle :if={@kind == :info} mini class="h-4 w-4" />
        <Heroicons.exclamation_circle :if={@kind == :error} mini class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-[0.8125rem] leading-5"><%= msg %></p>
      <button
        :if={@close}
        type="button"
        class="group absolute top-2 right-1 p-2"
        aria-label={gettext("close")}
      >
        <Heroicons.x_mark solid class="h-5 w-5 stroke-current opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={:user} phx-change="validate" phx-submit="save">
        <.input field={{f, :email}} label="Email"/>
        <.input field={{f, :username}} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, default: nil, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="space-y-5 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions}>
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75",
        "btn-primary active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any
  attr :name, :any
  attr :label, :string, default: nil

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week placeholder)

  attr :value, :any
  attr :field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}"
  attr :errors, :list
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :clear, :any
  attr :rest, :global, include: ~w(autocomplete disabled form max maxlength min minlength
                                   pattern placeholder readonly required size step)
  slot :inner_block

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
            "search-input block w-full rounded-md border-gray-300 pl-9 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
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
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          input_border(@errors),
          "block w-full rounded-md shadow-sm border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp input_border([] = _errors),
    do: "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5"

  defp input_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class={"block text-sm font-medium leading-6 text-zinc-800 capitalize #{@class}"}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <Heroicons.exclamation_circle mini class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :row_click, :any, default: nil
  attr :rows, :list, required: true
  attr :headers, :boolean, default: true

  slot :col, required: true do
    attr :label, :string
    attr :th_class, :string
    attr :td_class, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    ~H"""
    <div id={@id} class="overflow-y-auto divide-y divide-gray-300 px-4 sm:overflow-visible sm:px-0">
      <table class="mt-2 w-[40rem] sm:w-full">
        <thead :if={@headers} class="bg-gray-50 text-left text-[0.8125rem] leading-6 text-zinc-500">
          <tr>
            <th
              :for={col <- @col}
              class={"py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-600 #{col[:th_class]}"}
            >
              <%= col[:label] %>
            </th>
            <th class="p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200 bg-white font-medium text-sm leading-6 text-zinc-700">
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
                <span class={[i == 0 && "font-semibold text-zinc-900"]}>
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

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <Heroicons.arrow_left solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Render an item menu

  ## Examples

      <.item_menu id="team-menu" items={@items} link={fn item -> ~p"/items/{item.id}" end}>
        <:item_row :let={item}>
          <%= item.title %>
        </:item_row>
      </.item_menu>
  """
  attr :id, :string, required: true
  attr :items, :list
  attr :link, :any

  slot :item_row, required: true do
    attr :item, :any
  end

  def item_menu(assigns) do
    ~H"""
    <ul role="list" class="mt-4 divide-y divide-gray-200 border-t border-b border-gray-200">
      <.link
        :for={item <- @items}
        :if={assigns[:link]}
        navigate={@link.(item)}
        class="flex items-center justify-between space-x-3 py-4 px-4 hover:bg-gray-50 cursor-pointer"
      >
        <%= render_slot(@item_row, item) %>
      </.link>
      <div
        :for={item <- @items}
        :if={!assigns[:link]}
        class="flex items-center justify-between space-x-3 py-4 px-4"
      >
        <%= render_slot(@item_row, item) %>
      </div>
    </ul>
    """
  end

  @doc """
  Render a top navigation menu

  ## Examples

      <.top_nav_menu id="top_nav_menu">
        <:item link={~p"/settings"} label="Settings" active={true}>
          <Heroicons.cog class="w-4 h-4 inline-block" />
        </:item>
      </.top_nav_menu>
  """
  attr :id, :string, required: true

  slot :item, required: true do
    attr :link, :any
    attr :active, :boolean
    attr :label, :string
  end

  def top_nav_menu(assigns) do
    ~H"""
    <div>
      <nav class="px-7 py-4 isolate flex divide-x divide-gray-200 rounded-lg">
        <.link
          :for={item <- @item}
          navigate={item[:link]}
          class="text-slate-500 hover:text-slate-700 group relative min-w-0 flex-1 overflow-hidden bg-slate-50 py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10"
        >
          <%= render_slot(item) %>
          <span><%= item[:label] %></span>
          <span
            aria-hidden="true"
            class={[
              "#{if item[:active],
                do: "bg-indigo-500 absolute inset-x-0 bottom-0 h-0.5",
                else: "bg-transparent absolute inset-x-0 bottom-0 h-0.5"}"
            ]}
          >
          </span>
        </.link>
      </nav>
    </div>
    """
  end

  @doc """
  Renders an avatar.

  ## Examples

      <.avatar name={team.name} class="h-9 w-9" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: ""
  attr :round, :boolean, default: true

  def avatar(assigns) do
    ~H"""
    <div class="flex-shrink-0 select-none">
      <div class={[
        "#{@class} #{LiveHelpers.generate_gradient(@name)} bg-gradient-to-r",
        "#{if @round, do: "rounded-full", else: "rounded-md"}",
        "inline-block text-white flex justify-center items-center font-bold capitalize"
      ]}>
        <%= String.first(@name) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders an avatar.

  ## Examples

      <.avatar_lg name={team.name} class="h-9 w-9" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: ""
  attr :round, :boolean, default: true

  def avatar_lg(assigns) do
    ~H"""
    <div class={[
      "#{@class} #{LiveHelpers.generate_gradient(@name)} bg-gradient-to-r",
      "select-none ml-7 w-52 h-52 flex justify-center items-center rounded-md"
    ]}>
      <div class={[
        "#{LiveHelpers.generate_gradient(@name, true)}",
        "border-4 border-white rounded-full p-1 w-32 h-32 flex",
        "justify-center items-center bg-gradient-to-r capitalize"
      ]}>
        <span class="text-6xl font-extrabold text-white">
          <%= String.first(@name) %>
        </span>
      </div>
    </div>
    """
  end

  @doc """
  Renders a small avatar.

  ## Examples

      <.avatar_sm name={app.name} />
  """
  def avatar_sm(assigns) do
    ~H"""
    <span class={[
      "#{KsomniaWeb.LiveHelpers.generate_gradient(@name)} bg-gradient-to-r opacity-60 mr-2",
      "capitalize text-xs font-mono border border-slate-100 rounded-md w-6 h-6 inline-block",
      "flex justify-center items-center font-normal"
    ]}>
      <%= String.first(@name) %>
    </span>
    """
  end

  @doc """
  Renders a commit badge.

  ## Examples

      <.commit_badge commit_hash={commit_hash} />
  """
  attr :commit_hash, :string, required: true

  def commit_badge(assigns) do
    ~H"""
    <span class="commit-badge"><%= String.slice(@commit_hash, 0, 7) %></span>
    """
  end

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
  attr :current_page, :integer, required: true
  attr :current_page_size, :integer, required: true
  attr :page_size, :integer, required: true
  attr :entry_count, :integer, required: true
  attr :surrounding_size, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :link, :any, required: true

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
            class={"#{if @current_page == 1, do: "z-10 bg-indigo-50 border-indigo-500 text-indigo-600", else: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50"} inline-flex items-center border px-4 py-2 text-sm font-medium focus:z-20"}
          >
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

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(KsomniaWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(KsomniaWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end
end
