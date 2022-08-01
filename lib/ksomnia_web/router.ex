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
    # get "/projects/:id", ProjectController, :show
    # get "/projects", ProjectController, :index

    live "/apps", AppLive.Index, :index
    live "/apps/new", AppLive.Index, :new
    live "/apps/:id/edit", AppLive.Index, :edit
    live "/apps/:id", AppLive.Show, :show
    live "/apps/:id/show/edit", AppLive.Show, :edit

    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id/edit", ProjectLive.Index, :edit
    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/show/edit", ProjectLive.Show, :edit
    live "/projects/:id/show/new_app", ProjectLive.Show, :new_app

    live "/error_identities/:id", ErrorIdentityLive.Show, :show
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", KsomniaWeb do
    pipe_through :api

    post "/projects", ProjectController, :create

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

      live_dashboard "/dashboard", metrics: KsomniaWeb.Telemetry
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
