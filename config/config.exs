# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ksomnia,
  ecto_repos: [Ksomnia.Repo],
  generators: [binary_id: true]

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
config :swoosh, :api_client, false

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
  version: "3.3.3",
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

config :ksomnia, :ai_hint, %{
  provider: Ksomnia.AIHint.ChatGPTHint,
  models: [
    "gpt-4",
    "gpt-4-0613",
    "gpt-4-32k",
    "gpt-4-32k-0613",
    "gpt-3.5-turbo",
    "gpt-3.5-turbo-0613",
    "gpt-3.5-turbo-16k-0613"
  ],
  default_model: "gpt-3.5-turbo"
}

config :ex_rated,
  timeout: 10_000,
  cleanup_rate: 10_000,
  persistent: false,
  name: :ex_rated,
  ets_table_name: :ets_rated_buckets

config :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  # find it at https://platform.openai.com/account/org-settings under "Organization ID"
  # organization_key: "your-organization-key",
  # optional, passed to [HTTPoison.Request](https://hexdocs.pm/httpoison/HTTPoison.Request.html) options
  http_options: [recv_timeout: 60_000]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
