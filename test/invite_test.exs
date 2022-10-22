defmodule Ksomnia.InviteTest do
  use Ksomnia.DataCase

  test "accept/2" do
    inviter = insert(:user, email: "inviter@test.test")
    team = insert(:team, name: "team")
    insert(:team_user, team: team, user: inviter)

    invitee = insert(:user, email: "invitee@test.test")
    invite = insert(:invite, email: invitee.email, inviter: inviter, team: team)

    assert Team.for_user(invitee) == []
    Invite.accept(invite, invitee)
    assert Team.for_user(invitee) == [team]
  end
end
