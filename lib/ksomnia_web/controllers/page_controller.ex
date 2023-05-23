defmodule KsomniaWeb.PageController do
  use KsomniaWeb, :controller
  alias Ksomnia.Repo
  alias Ksomnia.User

  def index(conn, _params) do
    user = conn.assigns[:user]

    if user do
      conn
      |> redirect(to: "/teams")
    else
      conn
      |> put_layout(html: {KsomniaWeb.Layouts, :unauthenticated})
      |> render(:index, user: user)
    end
  end

  def live_demo(conn, _params) do
    case Application.fetch_env(:ksomnia, :live_demo) do
      {:ok, %{user: user, url: url}} ->
        if user = Repo.get_by(User, email: user) do
          conn
          |> put_session(:user_id, user.id)
          |> redirect(to: url)
        else
          redirect(conn, to: "/")
        end

      _ ->
        redirect(conn, to: "/")
    end
  end
end
