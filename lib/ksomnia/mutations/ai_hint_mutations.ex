defmodule Ksomnia.Mutations.AIHintMutations do
  alias Ksomnia.Repo
  alias Ksomnia.AIHint

  def create(error_identity, attrs) do
    AIHint.new(error_identity, attrs)
    |> Repo.insert()
  end
end
