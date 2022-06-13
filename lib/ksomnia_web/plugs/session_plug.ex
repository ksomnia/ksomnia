defmodule KsomniaWeb.SessionPlug do
  import Plug.Conn
  alias Ksomnia.User
  alias Ksomnia.Repo

  def init(default), do: default

  def call(conn, _default) do
    with user_id when is_binary(user_id) <- get_session(conn, :user_id),
         %User{} = user <- Repo.get(User, user_id) do
      conn
      |> assign(:user, user)
    else
      _ -> conn
    end
  end
end
