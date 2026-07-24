# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :go_champs_scoreboard,
  ecto_repos: [GoChampsScoreboard.Repo],
  generators: [timestamp_type: :utc_datetime]

config :go_champs_scoreboard, GoChampsScoreboard.Repo,
  migration_primary_key: [type: :uuid],
  migration_foreign_key: [type: :uuid],
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :go_champs_scoreboard, GoChampsScoreboardWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GoChampsScoreboardWeb.ErrorHTML, json: GoChampsScoreboardWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GoChampsScoreboard.PubSub,
  live_view: [signing_salt: "omrp2vU9"]

# Configure HTTP Client
config :go_champs_scoreboard, :http_client, http_client: HTTPoison
# :url is set at runtime (config/runtime.exs), since it's read via
# System.get_env and must reflect the deploy environment, not whatever
# was set when the release was compiled.

# RabbitMQ connection is configured at runtime (config/runtime.exs), since
# it's read via System.get_env and must reflect the deploy environment, not
# whatever was set when the release was compiled.

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :go_champs_scoreboard, GoChampsScoreboard.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  go_champs_scoreboard: [
    args:
      ~w(js/app.ts --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" =>
        Enum.join(
          [Path.expand("../deps", __DIR__), Path.expand("../assets/node_modules", __DIR__)],
          ":"
        )
    }
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:url, :response]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use to load SASS files
config :dart_sass,
  version: "1.77.8",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
