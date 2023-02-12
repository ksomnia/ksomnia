defmodule Ksomnia.Mutations.AppTokenMutations do
  alias Ksomnia.AppToken
  alias Ksomnia.Repo

  @spec create(binary(), binary()) :: {:ok, AppToken.t()} | {:error, Ecto.Changeset.t()}
  def create(app_id, user_id) do
    AppToken.new(app_id, user_id)
    |> Repo.insert()
  end

  def revoke(app_token) do
    app_token
    |> AppToken.put_revoked_at()
    |> Repo.update()
  end
end
