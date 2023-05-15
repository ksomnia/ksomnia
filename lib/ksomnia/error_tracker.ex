defmodule Ksomnia.ErrorTracker do
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.Mutations.ErrorIdentityMutations
  alias Ksomnia.Mutations.ErrorEventMutations
  alias Ksomnia.Queries.AppTokenQueries
  alias Ksomnia.Meilisearch

  def track(params) do
    with {:app_token, %AppToken{} = app_token} <-
           {:app_token, AppTokenQueries.find_by_token(params["token"])},
         {:app, %App{} = app} <- {:app, app_token.app},
         {_, {:ok, error_identity}} <-
           {:error_identity, ErrorIdentityMutations.create(app, params)} do
      ErrorEventMutations.create(app, error_identity, params)
      Meilisearch.create(error_identity, app.team_id)
      :ok
    end
  end
end
