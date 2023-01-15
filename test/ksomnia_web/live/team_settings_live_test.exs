defmodule KsomniaWeb.TeamSettingsLiveTest do
  use KsomniaWeb.ConnCase

  import Phoenix.LiveViewTest

  def create_team(_opts) do
    user = insert(:user, email: "user@test.test")
    team = insert(:team)
    insert(:team_user, user: user, team: team, role: "owner")

    %{user: user, team: team}
  end

  describe "the team settings page" do
    setup [:create_team]

    test "the user can leave the team", %{conn: conn, team: team} do
      user2 = insert(:user)
      insert(:team_user, user: user2, team: team)

      conn = login_as(conn, user2)
      url = ~p"/t/#{team.id}/settings"
      {:ok, index_live, _html} = live(conn, url)

      assert Repo.count(User.for_team(team)) == 2
      assert render_click(index_live, "leave-team", %{})
      assert Repo.count(User.for_team(team)) == 1
    end

    test "owner cannot leave the team if they are the single owner (a team must have at least one owner)",
         %{conn: conn, user: user, team: team} do
      user2 = insert(:user)
      insert(:team_user, user: user2, team: team, role: "owner")

      # The second owner leaves the team
      user2_conn = login_as(conn, user2)
      url = ~p"/t/#{team.id}/settings"
      {:ok, index_live, _html} = live(user2_conn, url)

      assert Repo.count(User.for_team(team)) == 2
      assert render_click(index_live, "leave-team", %{})
      assert Repo.count(User.for_team(team)) == 1

      # The last owner cannot leave the team
      user1_conn = login_as(conn, user)
      url = ~p"/t/#{team.id}/settings"
      {:ok, index_live, _html} = live(user1_conn, url)

      assert Repo.count(User.for_team(team)) == 1
      assert render_click(index_live, "leave-team", %{})
      assert Repo.count(User.for_team(team)) == 1
    end
  end
end
