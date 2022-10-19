defmodule KsomniaWeb.AppLiveTest do
  use KsomniaWeb.ConnCase

  import Phoenix.LiveViewTest

  def create_app(_opts) do
    user = insert(:user, email: "for_team@test.test")
    team = insert(:team)
    app = insert(:app, team: team)
    insert(:team_user, user: user, team: team)

    %{app: app, user: user, team: team}
  end

  describe "the user's home page" do
    setup [:create_app]

    test "displays the user's apps", %{conn: conn, app: app, user: user} do
      url = Routes.dashboard_index_path(conn, :index)
      conn = Plug.Test.init_test_session(conn, user_id: user.id)
      {:ok, _index_live, html} = live(conn, url)
      assert html =~ app.name
    end
  end
end
