defmodule KsomniaWeb.RequireCurrentUser do
  use KsomniaWeb, :controller
  alias Ksomnia.User

  def init(default), do: default

  def call(%{assigns: %{user: %User{} = _user}} = conn, _default) do
    conn
  end

  def call(conn, _) do
    conn
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
