defmodule KsomniaWeb.ErrorHTMLTest do
  use KsomniaWeb.ConnCase, async: true

  # Bring render_to_string/3 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(KsomniaWeb.ErrorHTML, "404", "html", []) == "Page Not Found"
  end

  # test "renders 500.html" do
  #   assert render_to_string(KsomniaWeb.ErrorHTML, "500", "html", []) == "Internal System Error"
  # end
end
