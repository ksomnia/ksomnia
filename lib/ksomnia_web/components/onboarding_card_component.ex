defmodule KsomniaWeb.OnboardingCardComponent do
  use KsomniaWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="onboarding-card" class="p-6 bg-slate-50 border border-slate-200 rounded-lg shadow-lg">
      <h3 class="text-lg font-medium text-slate-700 mb-4">Welcome to <%= @team.name %>!</h3>
      <p class="text-sm text-slate-600 mb-4">
        To start using the app, please follow these steps:
      </p>
      <ul class="list-disc text-sm text-slate-600 mb-4">
        <li>
          Take the application token from the
          <.link class="link" navigate={~p"/apps/#{@app.id}/settings/tokens"}>Tokens</.link>
          section.
        </li>
        <li>Set it in your client application.</li>
      </ul>
      <span
        class="link cursor-pointer"
        phx-click={
          JS.push("hide-onboarding")
          |> JS.hide(
            to: "#onboarding-card",
            time: 200,
            transition:
              {"transition-all transform ease-in duration-200",
               "opacity-100 translate-y-0 sm:scale-100",
               "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
          )
        }
        phx-target="#onboarding-card"
      >
        Do not show the onboarding message again.
      </span>
    </div>
    """
  end

  @impl true
  def handle_event("hide-onboarding", _params, socket) do
    team = socket.assigns.team
    current_user = socket.assigns.current_user

    Ksomnia.TeamUser.completed_onboarding(team, current_user)
    socket = socket |> assign(:hide_onboarding, true)
    {:noreply, socket}
  end
end
