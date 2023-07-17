defmodule KsomniaWeb.OnboardingCardComponent do
  use KsomniaWeb, :live_component
  alias Ksomnia.Mutations.TeamUserMutations

  @impl true
  def render(assigns) do
    ~H"""
    <div id="onboarding-card" class="p-6 bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 border border-slate-200 dark:border-indigo-400 rounded-lg shadow-lg">
      <h3 class="text-lg font-medium mb-4">
        Welcome to <%= @team.name %>, <%= @current_user.username %>!
      </h3>
      <p class="text-sm mb-4">
        To start using the app, please follow these steps:
      </p>
      <ul class="list-disc text-sm mb-4">
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
          |> hide("#onboarding-card")
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

    TeamUserMutations.complete_onboarding(team, current_user)
    {:noreply, socket}
  end
end
