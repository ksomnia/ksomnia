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

  describe "create" do
    test "creates an invite" do
      inviter = insert(:user, email: "inviter@test.test")
      team = insert(:team, name: "team")
      insert(:team_user, team: team, user: inviter)

      assert {:ok, %Invite{}} =
               Invite.create(team.id, %{
                 email: "invitee@test.test",
                 team_id: team.id,
                 inviter_id: inviter.id
               })
    end

    test "invitee is already a team member" do
      inviter = insert(:user, email: "inviter@test.test")
      team = insert(:team, name: "team")
      insert(:team_user, team: team, user: inviter)
      invitee = insert(:user, email: "invitee@test.test")
      insert(:team_user, team: team, user: invitee)

      assert {:error, changset} =
               Invite.create(team.id, %{
                 email: "invitee@test.test",
                 team_id: team.id,
                 inviter_id: inviter.id
               })

      [{_, {"the user is already a team member", []}}] = changset.errors
    end

    test "invite already exists" do
      inviter = insert(:user, email: "inviter@test.test")
      team = insert(:team, name: "team")
      insert(:team_user, team: team, user: inviter)
      insert(:invite, email: "invitee@test.test", inviter: inviter, team: team)

      assert {:error, changset} =
               Invite.create(team.id, %{
                 email: "invitee@test.test",
                 team_id: team.id,
                 inviter_id: inviter.id
               })

      assert [email: {"has already been invited", _}] = changset.errors
    end
  end
end
