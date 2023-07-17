defmodule Ksomnia.Mutations.AIHintMutations do
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.Repo
  alias Ksomnia.AIHint
  alias Ksomnia.Mutations.AppTokenMutations
  alias Ecto.Multi

  def create(error_identity, attrs) do
    AIHint.new(error_identity, attrs)
    |> Repo.insert()
  end
end
