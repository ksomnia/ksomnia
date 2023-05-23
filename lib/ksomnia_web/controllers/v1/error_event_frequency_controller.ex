defmodule KsomniaWeb.ErrorEventFrequencyController do
  use KsomniaWeb, :controller
  alias Ksomnia.Queries.ErrorIdentityQueries
  alias Ksomnia.Queries.ErrorEventQueries
  alias Ksomnia.Queries.AppQueries
  alias Ksomnia.Permissions
  require Logger

  def error_identity_frequencies(conn, %{"id" => error_identity_id}) do
    user = conn.assigns.user

    with {_, ei} <- {:error_identity, ErrorIdentityQueries.get_by_id(error_identity_id)},
         {_, app} <- {:app, AppQueries.get_by_id(ei.app_id)},
         true <- Permissions.can_view_app(user, app) do
      json(conn, ErrorEventQueries.error_identity_frequencies(ei))
    end
  end

  def app_frequencies(conn, %{"id" => app_id}) do
    user = conn.assigns.user

    with {_, app} <- {:app, AppQueries.get_by_id(app_id)},
         true <- Permissions.can_view_app(user, app) do
      json(conn, ErrorEventQueries.app_frequencies(app))
    end
  end
end
