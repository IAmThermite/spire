# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :upload_compiler,
  ecto_repos: [Spire.SpireDB.Repo]

config :upload_compiler,
  sqs_queue_url: System.get_env("SPIRE_SQS_QUEUE_URL") || raise("SPIRE_SQS_QUEUE_URL not set!")

config :logger,
  backends: [:console, {Airbrake.LoggerBackend, :error}]

config :airbrake,
  api_key: System.get_env("AIRBRAKE_API_KEY"),
  project_id: System.get_env("AIRBRAKE_PROJECT_ID"),
  environment: Mix.env,
  host: System.get_env("AIRBRAKE_HOST"),
  json_encoder: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
