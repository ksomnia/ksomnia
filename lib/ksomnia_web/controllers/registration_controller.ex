defmodule KsomniaWeb.RegistrationController do
  use KsomniaWeb, :controller
  alias Ksomnia.User

  def new(conn, _params) do
    render(conn, :new, changeset: User.new(%{}))
  end

  def create(conn, params) do
    with {:ok, user} <- User.create(params["user"]) do
      conn
      |> put_session(:user_id, user.id)
      |> redirect(to: "/")
    else
      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
