defmodule Ksomnia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ksomnia.Repo,
      # Start the Telemetry supervisor
      Ksomnia.ClickhouseRepo,
      Ksomnia.ClickhouseReadRepo,
      KsomniaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ksomnia.PubSub},
      # Start the Endpoint (http/https)
      KsomniaWeb.Endpoint
      # Start a worker by calling: Ksomnia.Worker.start_link(arg)
      # {Ksomnia.Worker, arg}
    ]

    case Application.get_env(:ksomnia, :app_hooks) do
      nil ->
        nil

      hooks ->
        Enum.each(hooks, fn {mod, fun, args} ->
          apply(mod, fun, args)
        end)
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ksomnia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KsomniaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
