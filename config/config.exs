# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config
import_config "../apps/*/config/config.exs"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


config :logger, :console,
  format: {Spire.LogFormatter, :format},
  metadata: :all

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
