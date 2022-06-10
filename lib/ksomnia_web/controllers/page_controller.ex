defmodule KsomniaWeb.PageController do
  use KsomniaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
