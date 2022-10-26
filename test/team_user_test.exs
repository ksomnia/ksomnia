defmodule Ksomnia.TeamUserTest do
  use Ksomnia.DataCase

  describe "remove_user/2" do
    test "removes the user from team along with the associated data" do
      user = insert(:user)
      team = insert(:team)
      insert(:team_user, user: user, team: team, role: "owner")
      user2 = insert(:user)
      invite = insert(:invite, email: user2.email, team: team)
      Invite.accept(invite, user2)

      assert [_] = Repo.all(Invite)
      TeamUser.remove_user(team, user2)
      assert [] = Repo.all(Invite)
      refute Repo.get_by(TeamUser, user_id: user2.id, team_id: team.id)
    end
  end
end
