defmodule KsomniaWeb.AccountLive.AccountNavComponent do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="w-36 text-gray-600 mr-4">
      <%= live_redirect [
        to: Routes.account_profile_path(@socket, :profile),
        class: "#{if @current_section == :profile, do: "bg-indigo-50", else: "bg-transparent"} block hover:bg-indigo-50 cursor-pointer rounded-sm px-2 py-2 text-sm text-slate-500"
      ] do %>
        Profile
      <% end %>
      <%= live_redirect [
        to: Routes.account_password_path(@socket, :password),
        class: "#{if @current_section == :password, do: "bg-indigo-50", else: "bg-transparent"} block hover:bg-indigo-50 cursor-pointer rounded-sm px-2 py-2 text-sm text-slate-500"
      ] do %>
        Password
      <% end %>
      <div class="bg-red-50 hover:bg-red-100 cursor-pointer rounded-sm px-2 py-2 text-sm text-slate-500">Log out</div>
    </div>
    """
  end
end
