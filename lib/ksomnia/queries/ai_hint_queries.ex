defmodule Ksomnia.Queries.AIHintQueries do
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.AIHint
  alias Ksomnia.Repo

  def latest_for_prompt(error_identity_id, prompt) do
    prompt_hash = Ksomnia.Security.hash_sha256(prompt)

    from(aih in AIHint,
      where: aih.prompt_hash == ^prompt_hash,
      order_by: [desc: aih.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end
end
