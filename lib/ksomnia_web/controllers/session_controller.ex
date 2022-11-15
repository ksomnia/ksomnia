defmodule KsomniaWeb.SessionController do
  use KsomniaWeb, :controller
  alias Ksomnia.Auth

  def new(conn, _params) do
    conn
    |> put_root_layout(:root)
    |> render(:new)
  end

  def create(conn, params) do
    with {:ok, user} <- Auth.verify_user(params) do
      conn
      |> put_session(:user_id, user.id)
      |> redirect(to: "/")
    else
      _ ->
        render(conn, :new, error: "Invalid email or password")
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> redirect(to: "/")
  end
end
