defmodule KsomniaWeb.TrackerApi.V1.TrackerController do
  use KsomniaWeb, :controller
  action_fallback KsomniaWeb.TrackerApi.V1.FallbackController

  def track(conn, _params) do
    with :ok <- Ksomnia.ErrorTracker.track(error_record_params(conn)) do
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
      "token" => String.trim(conn.params["token"]),
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
