# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :spire, SpireWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nccLXt6V5rNZO8UqUW3zCdLsiXZpk8gpViJL5DK5e50I+tqs/b34esaKtE0OOrhW",
  render_errors: [view: SpireWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Spire.PubSub, adapter: Phoenix.PubSub.PG2]

config :spire,
  ecto_repos: [SpireDb.Repo]

config :ueberauth, Ueberauth.Strategy.Steam,
  api_key: System.get_env("STEAM_API_KEY") || raise "STEAM_API_KEY not set!"

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "spire", 30}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "spire", 30}, :instance_role],
  region: "us-east-2",
  json_codec: Jason

config :ueberauth, Ueberauth,
  providers: [
    steam: {Ueberauth.Strategy.Steam, []}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
