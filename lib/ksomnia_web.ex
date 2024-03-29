defmodule KsomniaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use KsomniaWeb, :controller
      use KsomniaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt uploads)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        namespace: KsomniaWeb,
        formats: [:html, :json],
        layouts: [html: KsomniaWeb.Layouts]

      import Plug.Conn
      import KsomniaWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {KsomniaWeb.Layouts, :app}

      unquote(html_helpers())

      on_mount({KsomniaWeb.LiveCurrentUser, :current_user})
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import KsomniaWeb.CoreComponents
      import KsomniaWeb.CoreComponents.Modal
      import KsomniaWeb.CoreComponents.Flash
      import KsomniaWeb.CoreComponents.SimpleForm
      import KsomniaWeb.CoreComponents.Button
      import KsomniaWeb.CoreComponents.Input
      import KsomniaWeb.CoreComponents.Table
      import KsomniaWeb.CoreComponents.List
      import KsomniaWeb.CoreComponents.ItemMenu
      import KsomniaWeb.CoreComponents.TopNavMenu
      import KsomniaWeb.CoreComponents.SubNavMenu
      import KsomniaWeb.CoreComponents.Avatar
      import KsomniaWeb.CoreComponents.Pagination
      import KsomniaWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      import KsomniaWeb.LiveHelpers
      alias Ksomnia.Pagination
      alias Ksomnia.Permissions
      alias Ksomnia.Util

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: KsomniaWeb.Endpoint,
        router: KsomniaWeb.Router,
        statics: KsomniaWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
