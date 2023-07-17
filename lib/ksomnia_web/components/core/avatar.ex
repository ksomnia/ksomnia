defmodule KsomniaWeb.CoreComponents.Avatar do
  use Phoenix.Component
  alias KsomniaWeb.LiveHelpers

  @doc """
  Renders an avatar.

  ## Examples

      <.avatar name={team.name} class="h-9 w-9" />
  """
  attr(:name, :string, required: true)
  attr(:class, :string, default: "")
  attr(:round, :boolean, default: true)
  attr(:src, :string, default: nil)

  def avatar(assigns) do
    ~H"""
    <div class="flex-shrink-0 select-none">
      <%= if @src do %>
        <img
          src={@src}
          class="rounded-md w-9 h-9 inline-block mr-2 text-4xl group-hover:shadow-inner-dark group-hover:text-slate-500 ease-in duration-300"
        />
      <% else %>
        <div class={[
          "#{@class} #{LiveHelpers.generate_gradient(@name)} bg-gradient-to-r",
          "#{if @round, do: "rounded-full", else: "rounded-md"}",
          "inline-block text-white flex justify-center items-center font-bold capitalize"
        ]}>
          <%= String.first(@name) %>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders an avatar.

  ## Examples

      <.avatar_lg name={team.name} class="h-9 w-9" />
  """
  attr(:name, :string, required: true)
  attr(:class, :string, default: "")
  attr(:round, :boolean, default: true)

  def avatar_lg(assigns) do
    ~H"""
    <div class={[
      "#{@class} #{LiveHelpers.generate_gradient(@name)} bg-gradient-to-r",
      "select-none ml-7 w-52 h-52 flex justify-center items-center rounded-md"
    ]}>
      <div class={[
        "#{LiveHelpers.generate_gradient(@name, true)}",
        "border-4 border-white rounded-full p-1 w-32 h-32 flex",
        "justify-center items-center bg-gradient-to-r capitalize font-mono"
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

      <.avatar_sm name={app.name} src={app.avatar_path} />
  """
  def avatar_sm(assigns) do
    ~H"""
    <%= if @src do %>
      <img
        src={@src}
        class="rounded-md w-6 h-6 inline-block mr-2 text-4xl group-hover:shadow-inner-dark group-hover:text-slate-500 ease-in duration-300"
      />
    <% else %>
      <span class={[
        "#{KsomniaWeb.LiveHelpers.generate_gradient(@name)} bg-gradient-to-r opacity-60 mr-2",
        "capitalize text-xs font-mono border border-slate-100 rounded-md w-6 h-6 inline-block",
        "flex justify-center items-center font-normal font-mono dark:text-indigo-800 dark:border-slate-600"
      ]}>
        <%= String.first(@name) %>
      </span>
    <% end %>
    """
  end
end
