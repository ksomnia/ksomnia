defmodule Ksomnia.Meilisearch do
  def create(error_identity, team_id) do
    attrs = %{
      id: error_identity.id,
      app_id: error_identity.app_id,
      message: normalize(error_identity.message)
    }

    app_index = "error_identities-app_id-#{error_identity.app_id}"
    Meilisearch.Documents.add_or_replace(app_index, attrs)

    team_index = "error_identities-team_id-#{team_id}"
    Meilisearch.Documents.add_or_replace(team_index, attrs)
  end

  def search(index, term) do
    Meilisearch.Search.search(index, normalize(term))
  end

  def normalize(message) do
    message
    |> String.replace(~r/[^a-zA-Z0-9]+/, " ")
  end
end
