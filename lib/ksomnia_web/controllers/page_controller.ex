defmodule KsomniaWeb.PageController do
  use KsomniaWeb, :controller

  def index(conn, _params) do
    user = conn.assigns[:user]

    if user do
      conn
      |> put_root_layout({KsomniaWeb.LayoutView, "app_root.html"})
      |> render("app_index.html", user: user)
    else
      conn
      |> render("index.html", user: user)
    end
  end
end
