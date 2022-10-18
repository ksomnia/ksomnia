defmodule KsomniaWeb.PageControllerTest do
  use KsomniaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Create an account"
  end
end
