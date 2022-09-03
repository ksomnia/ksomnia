defmodule KsomniaWeb.PageController do
  use KsomniaWeb, :controller

  def index(conn, _params) do
    user = conn.assigns[:user]

    if user do
      conn
      |> redirect(to: "/projects")
    else
      conn
      |> render("index.html", user: user)
    end
  end

  def dummy_js_app(conn, _params) do
    conn
    |> render("dummy_js_app.html", [])
  end
end
