defmodule KsomniaWeb.AccountLive.AccountNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-36 text-gray-600 mr-4">
      <%= live_redirect [
        to: Routes.account_profile_path(@socket, :profile),
        class: "#{if @current_section == :profile, do: "border-indigo-600 text-indigo-600 border-l-2", else: "bg-transparent"} block hover:bg-slate-50 cursor-pointer px-2 py-2 text-sm font-medium text-slate-500"
      ] do %>
        Profile
      <% end %>
      <%= live_redirect [
        to: Routes.account_password_path(@socket, :password),
        class: "#{if @current_section == :password, do: "border-indigo-600 text-indigo-600 border-l-2", else: "bg-transparent"} block hover:bg-slate-50 cursor-pointer px-2 py-2 text-sm font-medium text-slate-500"
      ] do %>
        Password
      <% end %>
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
