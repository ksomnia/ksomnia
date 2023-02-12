defmodule Ksomnia.InviteTest do
  alias Ksomnia.Mutations.InviteMutations
  use Ksomnia.DataCase
  import Swoosh.TestAssertions

  test "accept/2" do
    inviter = create_user!(email: "inviter@test.test")
    team = create_team!(inviter)

    invitee = create_user!(email: "invitee@test.test")
    invite = create_invite!(team, inviter, email: invitee.email)

    assert TeamQueries.for_user(invitee) == []
    InviteMutations.accept(invite.id, invitee)
    assert TeamQueries.for_user(invitee) == [team]
  end

  describe "create" do
    test "invitee is already a team member" do
      inviter = create_user!(email: "inviter@test.test")
      team = create_team!(inviter)

      invitee = create_user!(email: "invitee@test.test")
      invite = create_invite!(team, inviter, email: invitee.email)
      InviteMutations.accept(invite.id, invitee)

      assert {:error, changset} =
               InviteMutations.create(team.id, inviter.id, %{
                 email: "invitee@test.test",
                 team_id: team.id,
                 inviter_id: inviter.id
               })

      [{_, {"the user is already a team member", []}}] = changset.errors
    end

    test "invite already exists" do
      inviter = create_user!(email: "inviter@test.test")
      team = create_team!(inviter)
      invitee = create_user!(email: "invitee@test.test")
      create_invite!(team, inviter, email: invitee.email)

      assert {:error, changset} =
               InviteMutations.create(team.id, inviter.id, %{
                 email: "invitee@test.test",
                 team_id: team.id
               })

      assert [email: {"has already been invited", _}] = changset.errors
    end

    test "send invite link" do
      inviter = create_user!()
      team = create_team!(inviter)

      assert {:ok, %Invite{} = invite} =
               InviteMutations.create(team.id, inviter.id, %{
                 email: "invitee@test.test",
                 team_id: team.id,
                 inviter_id: inviter.id
               })

      assert {:ok, email} = Ksomnia.UserInviteEmail.pending_invite_notification(invite)
      assert_email_sent(email)
    end
  end
end
