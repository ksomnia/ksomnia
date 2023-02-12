defmodule Ksomnia.Mutations.AppMutations do
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.Repo
  alias Ecto.Multi

  @spec create(binary(), binary(), map()) ::
          {:ok, %{app: App.t(), app_token: TeamAppTokenUser.t()}} | {:error, :any}
  def create(team_id, user_id, attrs) do
    Multi.new()
    |> Multi.insert(:app, App.new(team_id, attrs))
    |> Multi.run(:app_token, fn _repo, %{app: app} ->
      AppToken.create(app.id, user_id)
    end)
    |> Repo.transaction()
  end

  @spec update(Team.t(), map()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update(app, attrs) do
    app
    |> App.changeset(attrs)
    |> Repo.update()
  end
end
