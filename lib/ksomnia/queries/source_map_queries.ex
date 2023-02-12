defmodule Ksomnia.Queries.SourceMapQueries do
  import Ecto.Query
  alias Ksomnia.SourceMap
  alias Ksomnia.App
  alias Ksomnia.Repo

  @spec latest_for_commit_hash(binary()) :: SourceMap.t() | nil
  def latest_for_commit_hash(commit_hash) do
    from(s in SourceMap,
      where: s.commit_hash == ^commit_hash,
      order_by: [desc: :inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  @spec latest_for_commit_hash(App.t()) :: App.t() | nil
  def latest_for_app(app) do
    from(s in SourceMap,
      where: s.app_id == ^app.id,
      order_by: [desc: :inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  @spec for_app(App.t()) :: Ecto.Query.t()
  def for_app(app) do
    from(s in SourceMap,
      where: s.app_id == ^app.id,
      order_by: [desc: :inserted_at]
    )
  end
end
