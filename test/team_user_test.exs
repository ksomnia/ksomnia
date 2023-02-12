defmodule Ksomnia.TeamUserTest do
  alias Ksomnia.Mutations.TeamUserMutations
  alias Ksomnia.Queries.TeamUserQueries
  alias Ksomnia.Mutations.InviteMutations
  use Ksomnia.DataCase

  describe "remove_user/2" do
    test "removes the user from team along with the associated data" do
      user = create_user!()
      user2 = create_user!()
      team = create_team!(user)
      add_user_to_team!(team, user, user2)

      assert [_] = repo_all(Invite)
      TeamUserMutations.remove_user(team, user2)
      assert [] = repo_all(Invite)
      refute TeamUserQueries.get_by_team_id_and_user_id(team.id, user2.id)
    end
  end
end
