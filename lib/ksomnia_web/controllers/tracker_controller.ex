defmodule KsomniaWeb.TrackerController do
  use KsomniaWeb, :controller

  alias Ksomnia.App
  alias Ksomnia.ErrorRecord
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.Repo

  def track(conn, %{"token" => token} = params) do
    with {:app, app} <- {:app, Repo.get_by(App, token: token)},
         {_, {:ok, error_identity}} <-
           {:error_identity, ErrorIdentity.create(app, error_record_params(conn))},
         {:tracked, _} <-
           {:tracked, ErrorRecord.track(app, error_identity, error_record_params(conn))} do
      json(conn, %{status: "ok"})
    else
      error ->
        {:error, error}
    end
  end

  def error_record_params(conn) do
    {a, b, c, d} = conn.remote_ip

    Map.merge(conn.params, %{
      "ip_address" => "#{a}.#{b}.#{c}.#{d}",
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
