# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :where_machines,
  ecto_repos: [WhereMachines.Repo],
  generators: [timestamp_type: :utc_datetime]

config :where_machines, WhereMachines.AutoSpawner,
interval: 60_000,  # 1 minute between spawns
regions: [:ams, :ord, :syd, :lhr, :yyz], # Subset of regions to use
auto_start: true   # Start spawning on application boot

# Configures the endpoint
config :where_machines, WhereMachinesWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WhereMachinesWeb.ErrorHTML, json: WhereMachinesWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: :where_pubsub,
  live_view: [signing_salt: "2yDWHFHp"]

  # Configures the endpoint
  config :where_machines, WhereMachinesWeb.APIEndpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: WhereMachinesWeb.ErrorHTML, json: WhereMachinesWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: :where_pubsub


# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  where_machines: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  where_machines: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
