defmodule KsomniaWeb.PageController do
  use KsomniaWeb, :controller

  def index(conn, _params) do
    user = conn.assigns[:user]

    render(conn, "index.html", user: user)
  end
end
