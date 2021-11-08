defmodule Tipay.MixProject do
  use Mix.Project

  def project do
    [
      app: :tipay,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Tipay.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:elixir_make, "~> 0.6.2"},
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:ecto_enum, "~> 1.4"},
      {:money, "~> 1.8"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.1"},
      {:shorter_maps, "~> 2.2"},

      # Scheduled tasks
      {:quantum, "~> 3.3"},

      # Crypt
      {:guardian, "~> 2.1"},
      {:comeonin, "~> 5.0"},
      {:bcrypt_elixir, "~> 2.2"},

      # Auth and Acl
      {:bodyguard, "~> 2.4"},

      # GraphQL
      {:absinthe, "~> 1.5"},
      {:absinthe_plug, "~> 1.5"},
      {:cors_plug, "~> 2.0"},

      # HTTP Client
      {:tesla, "~> 1.4.0"},
      {:castore, "~> 0.1.0"},
      {:mint, "~> 1.0"},

      # File uploads
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.0"},

      # Testing
      {:ex_machina, "~> 2.2", only: :test},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:assertions, "~> 0.10", only: :test},

      # Code Analysis
      {:credo, "~> 1.5"},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup", "run priv/repo/seeds.exs"],
      "ecto.reset-test": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
