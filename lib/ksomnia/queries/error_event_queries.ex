defmodule Ksomnia.Queries.ErrorEventQueries do
  import Ecto.Query
  alias Ksomnia.Schemas.ErrorEventView
  alias Ksomnia.ClickhouseReadRepo

  def for_error_identity(error_identity) do
    {:ok, error_identity_id} = ShortUUID.decode(error_identity.id)

    query =
      from(e in ErrorEventView,
        where: e.error_identity_id == ^error_identity_id,
        order_by: [desc: e.inserted_at]
      )

    ClickhouseReadRepo.all(query)
  end

  def get_error_events() do
    query =
      from(e in ErrorEventView,
        order_by: [desc: e.id],
        limit: 10
      )

    ClickhouseReadRepo.all(query)
  end
end
