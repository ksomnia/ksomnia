defmodule Ksomnia.ErrorTracker do
  alias Ksomnia.App
  alias Ksomnia.ErrorRecord
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.Repo

  def track(params) do
    with {:app, %App{} = app} <- {:app, Repo.get_by(App, token: params["token"])} |> IO.inspect(),
         {_, {:ok, error_identity}} <-
           {:error_identity, ErrorIdentity.create(app, params)} |> IO.inspect(),
         {:tracked, _} <-
           {:tracked, ErrorRecord.track(app, error_identity, params)} |> IO.inspect() do
      :ok
    end
  end
end
