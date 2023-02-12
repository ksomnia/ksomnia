defmodule Ksomnia.Mutations.TeamUserMutations do
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.User
  alias Ksomnia.Repo
  alias Ksomnia.Queries.TeamUserQueries
  alias Ksomnia.Mutations.InviteMutations

  @spec remove_user(Team.t(), User.t()) :: {:ok, TeamUser.t()} | {:error, any()}
  def remove_user(%Team{} = team, %User{} = target_user) do
    with %TeamUser{} = team_user <-
           TeamUserQueries.get_by_team_id_and_user_id(team.id, target_user.id),
         _ <- InviteMutations.delete_if_exists(target_user.email, team.id),
         {:ok, _} <- Repo.delete(team_user) do
      {:ok, team_user}
    end
  end

  @spec complete_onboarding(Team.t(), User.t()) :: :ok | {:error, any()}
  def complete_onboarding(team, target_user) do
    with %TeamUser{} = team_user <-
           TeamUserQueries.get_by_team_id_and_user_id(team.id, target_user.id),
         {:ok, _} <- Repo.update(TeamUser.complete_onboarding(team_user)) do
      :ok
    end
  end

  @spec make_owner(binary(), binary()) :: TeamUser.t() | nil
  def make_owner(team_id, target_user_id) do
    with %TeamUser{} = team_user <-
           TeamUserQueries.get_by_team_id_and_user_id(team_id, target_user_id) do
      team_user
      |> Ecto.Changeset.change(role: "owner")
      |> Repo.update()
    end
  end
end
