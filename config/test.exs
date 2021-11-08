use Mix.Config

# Configure your database
config :tipay, Tipay.Repo,
  username: "postgres",
  password: "postgres",
  database: "tipay_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tipay, TipayWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Speed up tests by simplifying hash generation
config :bcrypt_elixir, log_rounds: 4

# Mocking Tesla client requests to external APIs
config :tesla, adapter: Tesla.Mock

config :tipay, :tpay_api, Tipay.Tpay.InMemory

config :tipay,
  system_url: "https://test.tivent.eu/"
