defmodule Ksomnia.Mutations.TeamMutations do
  alias Ksomnia.Repo
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.User
  alias Ecto.Multi

  @spec create(User.t(), map()) ::
          {:ok, %{team: Team.t(), team_user: TeamUser.t()}} | {:error, any()}
  def create(user, attrs) do
    Multi.new()
    |> Multi.insert(:team, Team.new(attrs))
    |> Multi.insert(:team_user, fn %{team: team} ->
      TeamUser.new(team.id, user.id, %{role: "owner"})
    end)
    |> Repo.transaction()
  end

  @spec update(Team.t(), map()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update(team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end
end
