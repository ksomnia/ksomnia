defmodule Ksomnia.ErrorTracker do
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.Mutations.ErrorIdentityMutations
  alias Ksomnia.Queries.AppTokenQueries

  def track(params) do
    with {:app_token, %AppToken{} = app_token} <-
           {:app_token, AppTokenQueries.find_by_token(params["token"])},
         {:app, %App{} = app} <- {:app, app_token.app},
         {_, {:ok, error_identity}} <-
           {:error_identity, ErrorIdentityMutations.create(app, params)} do
        #  {:tracked, _} <-
        #    {:tracked, ErrorRecord.track(app, error_identity, params)} do
      Ksomnia.Schemas.ErrorEvent.new(app, error_identity, params)
      Ksomnia.Meilisearch.create(error_identity, app.team_id)
      :ok
    end
  end
end
