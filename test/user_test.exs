defmodule Ksomnia.UserTest do
  use Ksomnia.DataCase

  test "for_team/1" do
    user = insert(:user, email: "for_team@test.test")
    team = insert(:team)
    insert(:team_user, user: user, team: team)
    assert User.for_team(team) == [user]
  end
end
