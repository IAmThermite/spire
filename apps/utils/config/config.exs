# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :utils,
  steam_api_key: System.get_env("STEAM_API_KEY") || raise("STEAM_API_KEY not set!")

config :utils,
  sqs_queue: System.get_env("SPIRE_SQS_QUEUE") || raise("SPIRE_SQS_QUEUE not set!")
