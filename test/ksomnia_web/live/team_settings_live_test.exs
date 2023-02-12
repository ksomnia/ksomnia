defmodule KsomniaWeb.TeamSettingsLiveTest do
  use KsomniaWeb.ConnCase

  import Phoenix.LiveViewTest

  def create_user_and_team(_opts) do
    user = create_user!(email: "user@test.test")
    team = create_team!(user)

    %{user: user, team: team}
  end

  describe "the team settings page" do
    setup [:create_user_and_team]

    test "the user can leave the team", %{conn: conn, user: user, team: team} do
      user2 = create_user!()
      add_user_to_team!(team, user, user2)

      conn = login_as(conn, user2)
      url = ~p"/t/#{team.id}/settings"
      {:ok, index_live, _html} = live(conn, url)

      assert repo_count(UserQueries.for_team(team)) == 2
      assert render_click(index_live, "leave-team", %{})
      assert repo_count(UserQueries.for_team(team)) == 1
    end

    test "owner cannot leave the team if they are the single owner (a team must have at least one owner)",
         %{conn: conn, user: user, team: team} do
      user2 = create_user!()
      add_user_to_team!(team, user, user2)
      make_owner(team, user2)

      # The second owner leaves the team
      user2_conn = login_as(conn, user2)
      url = ~p"/t/#{team.id}/settings"
      {:ok, index_live, _html} = live(user2_conn, url)

      assert repo_count(UserQueries.for_team(team)) == 2
      assert render_click(index_live, "leave-team", %{})
      assert repo_count(UserQueries.for_team(team)) == 1

      # The last owner cannot leave the team
      user1_conn = login_as(conn, user)
      url = ~p"/t/#{team.id}/settings"
      {:ok, index_live, _html} = live(user1_conn, url)

      assert repo_count(UserQueries.for_team(team)) == 1
      assert render_click(index_live, "leave-team", %{})
      assert repo_count(UserQueries.for_team(team)) == 1
    end
  end
end
