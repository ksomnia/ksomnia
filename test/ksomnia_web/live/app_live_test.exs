defmodule KsomniaWeb.AppLiveTest do
  use KsomniaWeb.ConnCase
  import Phoenix.LiveViewTest

  def create_app(_opts) do
    user = create_user!(email: "user@test.test")
    team = create_team!(user)
    app = create_app!(team, user)

    %{app: app, user: user, team: team}
  end

  describe "the user's home page" do
    setup [:create_app]

    test "displays the user's invites", %{conn: conn, user: user} do
      invitee = insert(:user, email: "invitee@test.test")
      insert(:invite, email: invitee.email, inviter: user)

      conn = login_as(conn, invitee)
      {:ok, _index_live, html} = live(conn, ~p"/teams")
      assert html =~ "Pending invites"
    end

    test "the user accepts an invite", %{conn: conn, user: user, team: team} do
      invitee = create_user!(email: "invitee@test.test")
      invite = insert(:invite, email: invitee.email, inviter: user, team: team)

      conn = login_as(conn, invitee)
      {:ok, index_live, _html} = live(conn, ~p"/teams")

      assert render_click(index_live, "accept-invite", %{"invite-id" => invite.id})
      assert TeamQueries.for_user(invitee) == [team]
    end

    test "the user rejects an invite", %{conn: conn, user: user, team: team} do
      invitee = insert(:user, email: "invitee@test.test")
      invite = insert(:invite, email: invitee.email, inviter: user, team: team)

      conn = login_as(conn, invitee)
      {:ok, index_live, _html} = live(conn, ~p"/teams")

      assert render_click(index_live, "reject-invite", %{"invite-id" => invite.id})
      assert TeamQueries.for_user(invitee) == []
    end
  end
end
