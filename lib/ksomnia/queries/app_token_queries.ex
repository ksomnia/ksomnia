defmodule Ksomnia.Queries.AppTokenQueries do
  import Ecto.Query
  alias Ksomnia.Repo
  alias Ksomnia.AppToken

  @spec all(binary()) :: Ecto.Query.t()
  def all(app_id) do
    from(a in AppToken,
      join: u in assoc(a, :user),
      where: a.app_id == ^app_id,
      order_by: [asc: not is_nil(a.revoked_at), desc: :inserted_at],
      preload: [:user]
    )
  end

  @spec find_by_token(binary()) :: AppToken.t() | nil
  def find_by_token(token) do
    AppToken
    |> where(token: ^token)
    |> preload(:app)
    |> Repo.one()
  end

  @spec find_by_id(binary()) :: AppToken.t() | nil
  def find_by_id(id) do
    AppToken
    |> where(id: ^id)
    |> preload(:app)
    |> Repo.one()
  end
end
