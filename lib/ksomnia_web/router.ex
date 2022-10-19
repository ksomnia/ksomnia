defmodule KsomniaWeb.Router do
  use KsomniaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KsomniaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug KsomniaWeb.SessionPlug
  end

  pipeline :authenticated_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KsomniaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug KsomniaWeb.SessionPlug
    plug KsomniaWeb.RequireCurrentUser
  end

  pipeline :api do
    plug :fetch_session
    plug :accepts, ["json"]
    plug KsomniaWeb.SessionPlug
  end

  scope "/", KsomniaWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/signin", SessionController, :new
    post "/signin", SessionController, :create
    get "/logout", SessionController, :logout
    get "/signup", RegistrationController, :new
    post "/signup", RegistrationController, :create
    get "/password-reset", RegistrationController, :password_reset
    post "/password-reset", RegistrationController, :do_password_reset

    if System.get_env("LIVE_DEMO_USER") && System.get_env("LIVE_DEMO_URL") do
      get "/live-demo", PageController, :live_demo
    end
  end

  scope "/", KsomniaWeb do
    pipe_through :authenticated_browser

    live "/teams", TeamLive.Index, :index
    live "/t/:team_id/apps", TeamLive.Apps, :apps
    live "/t/:team_id/settings", TeamLive.Settings, :settings
    live "/t/:team_id/invite", TeamLive.Members, :invite
    live "/t/:team_id/members/invites", TeamLive.Invites, :invites
    live "/t/:team_id/members", TeamLive.Members, :members
    live "/t/:team_id/", TeamLive.Default, :default
    live "/t/:team_id/new_app", TeamLive.Default, :new_app
    live "/dashboard", DashboardLive.Index, :index
    live "/apps/:id/settings", AppLive.Settings, :settings
    live "/apps/:id/source_maps", AppLive.SourceMaps, :source_maps
    live "/apps/:id", AppLive.Show, :show
    live "/account/profile", AccountLive.Profile, :profile
    live "/account/password", AccountLive.Password, :password
    live "/error_identities/:id", ErrorIdentityLive.Show, :show
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", KsomniaWeb do
    pipe_through :api

    post("/source_maps", SourceMapController, :create)
  end

  # Other scopes may use custom stacks.
  scope "/tracker_api/v1", KsomniaWeb.TrackerApi.V1 do
    pipe_through :api

    post("/track", TrackerController, :track)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/system-dashboard", metrics: KsomniaWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
