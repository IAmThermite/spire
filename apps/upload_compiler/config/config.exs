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
