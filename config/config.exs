# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ksomnia,
  ecto_repos: [Ksomnia.Repo]

# Configures the endpoint
config :ksomnia, KsomniaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KsomniaWeb.ErrorHTML, json: KsomniaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ksomnia.PubSub,
  live_view: [signing_salt: "8ETgfuCm"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ksomnia, Ksomnia.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, Swoosh.ApiClient.Finch

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    # ~w(js/app.js  --sourcemap=inline --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    args: ~w(),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.1.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :cors_plug,
  origin: ["http://localhost:5500"],
  max_age: 86400,
  methods: ["GET", "POST"]

config :meilisearch,
  endpoint: "http://127.0.0.1:7700",
  api_key: System.get_env("MEILISEARCH_API_KEY")

config :ksomnia,
  clickhouse_url: "http://localhost:8123"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
