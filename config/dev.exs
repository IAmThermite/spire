use Mix.Config

# Configure your database
config :spire_db, SpireDb.Repo,
  username: "postgres",
  password: "postgres",
  database: "spire_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
