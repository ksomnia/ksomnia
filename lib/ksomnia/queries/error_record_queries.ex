defmodule Ksomnia.Queries.ErrorRecordQueries do
  import Ecto.Query
  alias Ksomnia.ErrorRecord
  alias Ksomnia.ErrorIdentity

  @spec for_error_identity(ErrorIdentity.t()) :: Ecto.Query.t()
  def for_error_identity(error_identity) do
    from(er in ErrorRecord,
      where: er.error_identity_id == ^error_identity.id,
      order_by: [desc: er.inserted_at]
    )
  end
end
