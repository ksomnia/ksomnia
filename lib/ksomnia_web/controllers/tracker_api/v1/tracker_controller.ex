defmodule KsomniaWeb.TrackerApi.V1.TrackerController do
  use KsomniaWeb, :controller

  alias Ksomnia.App
  alias Ksomnia.ErrorRecord
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.Repo
  action_fallback KsomniaWeb.TrackerApi.V1.FallbackController

  def track(conn, %{"token" => token} = params) do
    token = String.trim(token)

    with {:app, %App{} = app} <- {:app, Repo.get_by(App, token: token)},
         {_, {:ok, error_identity}} <-
           {:error_identity, ErrorIdentity.create(app, error_record_params(conn))},
         {:tracked, _} <-
           {:tracked, ErrorRecord.track(app, error_identity, error_record_params(conn))} do
      json(conn, %{status: "ok"})
    else
      {:app, _} ->
        {:error, :not_found}

      error ->
        {:error, error}
    end
  end

  def error_record_params(conn) do
    id_address = Tuple.to_list(conn.remote_ip) |> Enum.join(".")

    Map.merge(conn.params, %{
      "ip_address" => id_address,
      "user_agent" => get_user_agent(conn),
      "line_number" => "#{conn.params["line_number"]}",
      "column_number" => "#{conn.params["column_number"]}"
    })
  end

  defp get_user_agent(conn) do
    with [user_agent] <- get_req_header(conn, "user-agent") do
      user_agent
    else
      _ -> nil
    end
  end
end
