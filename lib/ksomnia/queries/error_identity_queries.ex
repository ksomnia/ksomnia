defmodule Ksomnia.Queries.ErrorIdentityQueries do
  import Ecto.Query
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.App

  @spec get_by_ids([binary()]) :: Ecto.Query.t()
  def get_by_ids(ids) do
    from(e in ErrorIdentity, where: e.id in ^ids)
  end

  @spec for_app([App.t()]) :: Ecto.Query.t()
  def for_app(app) do
    from(er in ErrorIdentity, where: er.app_id == ^app.id, order_by: [desc: er.last_error_at])
  end
end
