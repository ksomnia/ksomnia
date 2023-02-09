defmodule Ksomnia.Permissions do
  alias Ksomnia.Queries.TeamUserQueries
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Invite
  alias Ksomnia.AppToken

  @spec can_revoke_user_invite(Team.t(), User.t(), Invite.t()) :: boolean()
  def can_revoke_user_invite(%Team{} = team, %User{} = user, %Invite{} = invite) do
    TeamUserQueries.is_owner(team, user) || invite.inviter_id == user.id
  end

  @spec can_update_team(Team.t(), User.t()) :: boolean()
  def can_update_team(%Team{} = team, %User{} = user) do
    TeamUserQueries.is_owner(team, user)
  end

  @spec can_remove_user_from_team(Team.t(), User.t(), User.t()) :: boolean()
  def can_remove_user_from_team(%Team{} = team, %User{} = current_user, %User{} = target_user) do
    TeamUserQueries.is_owner(team, current_user) && !TeamUserQueries.is_owner(team, target_user)
  end

  @spec can_leave_team(Team.t(), User.t()) :: boolean()
  def can_leave_team(%Team{} = team, %User{} = current_user) do
    !(TeamUserQueries.is_owner(team, current_user) && TeamUserQueries.team_has_single_owner(team))
  end

  @spec can_revoke_app_token(Team.t(), User.t(), AppToken.t()) :: boolean()
  def can_revoke_app_token(
        %Team{} = team,
        %User{} = current_user,
        %AppToken{} = app_token
      ) do
    TeamUserQueries.is_owner(team, current_user) || app_token.user_id == current_user.id
  end
end
