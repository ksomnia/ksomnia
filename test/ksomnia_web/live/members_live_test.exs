defmodule KsomniaWeb.MembersLiveTest do
  use KsomniaWeb.ConnCase
  use Ksomnia.QueryHelper
  import Phoenix.LiveViewTest

  def create_team(_opts) do
    user = insert(:user, email: "user@test.test")
    team = insert(:team)
    insert(:team_user, user: user, team: team, role: "owner")

    %{user: user, team: team}
  end

  describe "member list" do
    setup [:create_team]

    test "a user can be removed from the team by the team owner", %{
      conn: conn,
      user: user,
      team: team
    } do
      user2 = insert(:user)
      insert(:team_user, user: user2, team: team)

      conn = login_as(conn, user)
      url = ~p"/t/#{team.id}/members"
      {:ok, index_live, _html} = live(conn, url)

      assert count_for_query(UserQueries.for_team(team)) == 2
      assert render_click(index_live, "remove-team-member", %{"team-member-id" => user2.id})
      assert count_for_query(UserQueries.for_team(team)) == 1
    end

    test "a non-owner cannot remove a user from the team", %{conn: conn, team: team} do
      user2 = insert(:user)
      user3 = insert(:user)
      insert(:team_user, user: user2, team: team)
      insert(:team_user, user: user3, team: team)

      conn = login_as(conn, user3)
      url = ~p"/t/#{team.id}/members"
      {:ok, index_live, _html} = live(conn, url)

      assert count_for_query(UserQueries.for_team(team)) == 3
      assert render_click(index_live, "remove-team-member", %{"team-member-id" => user2.id})
      assert count_for_query(UserQueries.for_team(team)) == 3
    end
  end
end
