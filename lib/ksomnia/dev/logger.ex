defmodule Ksomnia.Dev.Logger do
  use Tesla

  @commit_hash Keyword.get(Application.compile_env(:ksomnia, :git_version), :commit)

  def attatch do
    :logger.add_handler(Ksomnia.Dev.Logger, Ksomnia.Dev.Logger, %{})
  end

  def track(attrs) do
    Ksomnia.ErrorTracker.track(%{
      "token" => "JzBxyCF8RatQUcmA",
      "message" => attrs[:message],
      "line_number" => to_string(attrs[:line_number]),
      "column_number" => to_string(attrs[:column_number]),
      "source" => to_string(attrs[:source]),
      "stacktrace" => attrs[:stacktrace],
      "commit_hash" => @commit_hash,
      "ip_address" => "0.0.0.0",
      "client_version" => "Elixir #{System.version()}; OTP #{:erlang.system_info(:otp_release)}",
      "user_agent" => "Elixir #{System.version()}; OTP #{:erlang.system_info(:otp_release)}"
    })
  end

  def get_application_source_line(stacktrace) do
    {:ok, current_app} = :application.get_application(__MODULE__)

    stacktrace
    |> Enum.find(fn stack ->
      file = Keyword.get(elem(stack, 3), :file)

      if file do
        case :application.get_application(elem(stack, 0)) do
          {:ok, ^current_app} ->
            true

          _ ->
            nil
        end
      end
    end)
    |> case do
      nil ->
        ""

      stack ->
        location = elem(stack, 3)
        "#{Keyword.get(location, :file)}:#{Keyword.get(location, :line)}"
    end
  end

  def log(log_event, _) do
    if log_event.level == :error do
      map = log_event.msg |> elem(1)

      if args = Map.get(map, :args) do
        stack = args |> Enum.at(4)
        message = stack |> elem(0) |> elem(0)
        source_line = stack |> elem(0) |> elem(1) |> Enum.at(1)
        stacktrace = stack |> elem(0) |> elem(1) |> Exception.format_stacktrace()

        track(%{
          message: "#{Exception.message(message)}",
          source: get_application_source_line(stack |> elem(0) |> elem(1)),
          line_number: source_line |> elem(3) |> Keyword.get(:line),
          column_number: source_line |> elem(2),
          stacktrace: stacktrace
        })
      end
    end
  end
end
