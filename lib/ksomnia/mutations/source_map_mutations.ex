defmodule Ksomnia.Mutations.SourceMapMutations do
  alias Ksomnia.SourceMap
  alias Ksomnia.Repo
  alias Ksomnia.App

  @spec create(App.t(), map()) :: {:ok, SourceMap.t()} | {:error, Ecto.Changeset.t()}
  def create(app, params) do
    %SourceMap{app_id: app.id}
    |> SourceMap.changeset(params)
    |> Repo.insert()
  end
end
