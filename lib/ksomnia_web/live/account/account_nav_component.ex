defmodule KsomniaWeb.AccountLive.AccountNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-36 text-gray-600 mr-4">
      <.link
        navigate={~p"/account/profile"}
        class={"#{if @current_section == :profile, do: "border-indigo-600 text-indigo-600 border-l-2", else: "bg-transparent"} block hover:bg-slate-50 cursor-pointer px-2 py-2 text-sm font-medium text-slate-500"}>
        Profile
      </.link>
      <.link
        navigate={~p"/account/password"}
        class={"#{if @current_section == :password, do: "border-indigo-600 text-indigo-600 border-l-2", else: "bg-transparent"} block hover:bg-slate-50 cursor-pointer px-2 py-2 text-sm font-medium text-slate-500"}>
        Password
      </.link>
      <div
        class="block hover:bg-slate-50 cursor-pointer rounded-sm px-2 py-2 text-sm font-medium text-red-400"
        @click="KsomniaHelpers.logout($event)"
      >
        Log out
      </div>
    </div>
    """
  end
end
