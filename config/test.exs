import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ksomnia, Ksomnia.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ksomnia_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ksomnia, KsomniaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mo+XfmMzTyO3g0H5Sfg2iSgBNtvuoJi/dY471NB/oPGKMBD7eM70Q36Vjw3FdvsL",
  server: false

# In test we don't send emails.
config :ksomnia, Ksomnia.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :argon2_elixir,
  t_cost: 1,
  m_cost: 4

config :ksomnia, :ai_hint, %{
  provider: Ksomnia.AIHint.MockHint,
  models: ["mock-1"],
  default_model: "mock-1"
}
