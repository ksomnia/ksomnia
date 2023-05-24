defmodule KsomniaWeb.RegistrationController do
  use KsomniaWeb, :controller
  alias Ksomnia.User
  alias Ksomnia.Mutations.UserMutations

  def new(conn, _params) do
    conn
    |> put_layout(html: {KsomniaWeb.Layouts, :unauthenticated})
    |> render(:new, changeset: User.new(%{}))
  end

  def create(conn, params) do
    with {:ok, user} <- UserMutations.create(params["user"]) do
      conn
      |> put_session(:user_id, user.id)
      |> redirect(to: "/")
    else
      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
