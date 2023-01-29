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
      KsomniaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ksomnia.PubSub},
      # Start the Endpoint (http/https)
      KsomniaWeb.Endpoint
      # Start a worker by calling: Ksomnia.Worker.start_link(arg)
      # {Ksomnia.Worker, arg}
    ]

    if Mix.env() == :dev do
      Ksomnia.Dev.Logger.attatch()
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
