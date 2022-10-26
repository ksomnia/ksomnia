defmodule Ksomnia.Permissions do
  alias Ksomnia.TeamUser
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Invite

  def can_revoke_user_invite(%Team{} = team, %User{} = user, %Invite{} = invite) do
    TeamUser.is_owner(team, user) || invite.inviter_id == user.id
  end

  def can_update_team(%Team{} = team, %User{} = user) do
    TeamUser.is_owner(team, user)
  end

  def can_remove_user_from_team(%Team{} = team, %User{} = current_user, %User{} = target_user) do
    TeamUser.is_owner(team, current_user) && !TeamUser.is_owner(team, target_user)
  end

  def can_leave_team(%Team{} = team, %User{} = current_user) do
    !(TeamUser.is_owner(team, current_user) && TeamUser.single_owner(team))
  end
end
