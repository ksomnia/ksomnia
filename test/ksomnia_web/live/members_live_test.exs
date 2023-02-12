defmodule KsomniaWeb.MembersLiveTest do
  use KsomniaWeb.ConnCase
  import Phoenix.LiveViewTest

  def create_user_and_team(_opts) do
    user = create_user!(email: "user@test.test")
    team = create_team!(user)

    %{user: user, team: team}
  end

  describe "member list" do
    setup [:create_user_and_team]

    test "a user can be removed from the team by the team owner", %{
      conn: conn,
      user: user,
      team: team
    } do
      user2 = create_user!()
      add_user_to_team!(team, user, user2)

      conn = login_as(conn, user)
      url = ~p"/t/#{team.id}/members"
      {:ok, index_live, _html} = live(conn, url)

      assert repo_count(UserQueries.for_team(team)) == 2
      assert render_click(index_live, "remove-team-member", %{"team-member-id" => user2.id})
      assert repo_count(UserQueries.for_team(team)) == 1
    end

    test "a non-owner cannot remove a user from the team", %{conn: conn, user: user, team: team} do
      user2 = create_user!()
      user3 = create_user!()
      add_user_to_team!(team, user, user2)
      add_user_to_team!(team, user, user3)

      conn = login_as(conn, user3)
      url = ~p"/t/#{team.id}/members"
      {:ok, index_live, _html} = live(conn, url)

      assert repo_count(UserQueries.for_team(team)) == 3
      assert render_click(index_live, "remove-team-member", %{"team-member-id" => user2.id})
      assert repo_count(UserQueries.for_team(team)) == 3
    end
  end
end
