defmodule Ksomnia.ErrorTracker do
  alias Ksomnia.App
  alias Ksomnia.AppToken
  alias Ksomnia.ErrorRecord
  alias Ksomnia.ErrorIdentity

  def track(params) do
    with {:app_token, %AppToken{} = app_token} <-
           {:app_token, AppToken.find_by_token(params["token"])},
         {:app, %App{} = app} <- {:app, app_token.app},
         {_, {:ok, error_identity}} <-
           {:error_identity, ErrorIdentity.create(app, params)},
         {:tracked, _} <-
           {:tracked, ErrorRecord.track(app, error_identity, params)} do
      Ksomnia.Meilisearch.create(error_identity, app.team_id)
      :ok
    end
  end
end