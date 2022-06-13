defmodule KsomniaWeb.SessionController do
  use KsomniaWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, _params) do
    render(conn, "new.html")
  end
end
