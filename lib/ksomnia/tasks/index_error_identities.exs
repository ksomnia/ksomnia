defmodule Ksomnia.Tasks.IndexErrorIdentities do
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.Repo
  alias Ksomnia.App
  alias Ksomnia.Team
  alias Meilisearch.Indexes
  alias Meilisearch.Documents

  def run() do
    Team
    |> Repo.all()
    |> Enum.each(fn team ->
      Indexes.delete("error_identities-team_id-#{team.id}")
      Indexes.create("error_identities-team_id-#{team.id}", primary_key: "id")
    end)

    apps = Repo.all(App)

    apps
    |> Enum.each(fn app ->
      Indexes.delete("error_identities-app_id-#{app.id}")
      Indexes.create("error_identities-app_id-#{app.id}", primary_key: "id")
    end)

    apps_by_team_id = Enum.reduce(apps, %{}, fn a, acc -> Map.put(acc, a.id, a.team_id) end)

    ErrorIdentity
    |> Repo.chunk(10)
    |> Stream.each(fn error_identities ->
      Enum.each(error_identities, fn error_identity ->
        Ksomnia.Meilisearch.create(error_identity, apps_by_team_id[error_identity.app_id])
      end)
    end)
    |> Stream.run()

    IO.puts("Done")
  end
end

Ksomnia.Tasks.IndexErrorIdentities.run()
