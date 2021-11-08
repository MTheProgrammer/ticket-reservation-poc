# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tipay, Tipay.Scheduler,
  jobs: [
    cancel_outdated_transactions: [
      schedule: "* * * * *",
      task: {Tipay.Scheduler.TransactionCleanup, :work, []},
      overlap: false
    ]
  ]

config :money,
  default_currency: :PLN,
  separator: ",",
  delimiter: ".",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false,
  fractional_unit: false,
  strip_insignificant_zeros: false

config :tesla, adapter: Tesla.Adapter.Mint, timeout: 5000
config :tesla, Tesla.Middleware.Logger, filter_headers: ["authorization"]

config :tipay, :tpay_api, Tipay.Tpay.HTTPClient

config :tipay,
  ecto_repos: [Tipay.Repo],
  transaction_expiry_seconds: 60,
  transaction_expiry_batch_size: 64,
  # TPay payment configuration
  api_key: System.get_env("TPAY_API_KEY") || "",
  api_password: System.get_env("TPAY_API_PASSWORD") || "",
  security_code: System.get_env("TPAY_SECURITY_CODE") || "",
  system_url: System.get_env("TPAY_APP_URL")

config :tipay, Tipay.Repo,
  migration_primary_key: [type: :uuid],
  migration_timestamps: [type: :utc_datetime_usec],
  pool_size: 20,
  queue_target: 10_000

config :tipay, TipayWeb.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "TipayWeb",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: %{"k" => "3gx0vXjUD2BJ8xfo_aQWIA", "kty" => "oct"},
  serializer: TipayWeb.Guardian

# Configures the endpoint
config :tipay, TipayWeb.Endpoint,
  url: [
    scheme: "https",
    port: String.to_integer(System.get_env("TIVENT_API_PORT") || "4000"),
    host: System.get_env("TIVENT_API_HOST") || "localhost"
  ],
  secret_key_base: "WxnOQ/CH11Dn1mwqwZ+Po4+s4mL7Z6fGYVWXgkYLlzcfCjwsQv6q7wflvkkO53IV",
  render_errors: [view: TipayWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Tipay.PubSub,
  live_view: [signing_salt: "v4gYk0iM"]

config :bodyguard,
  default_error: :unauthorized

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: System.get_env("TIVENT_UPLOADS_STORAGE_DIR", "/tmp/tipay/uploads/")

config :tipay, Tipay.EventAttachments.Main,
  image_sizes: %{portrait: {200, 300}, landscape: {300, 200}, thumb: {96, 96}},
  min_canvas_size: {400, 300},
  permitted_formats: [:png, :jpeg, :pdf],
  max_file_size: 5 * 1024 * 1024

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
