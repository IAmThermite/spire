use Mix.Config

# Configure your database
config :spire_db, Spire.SpireDB.Repo,
  username: System.get_env("DB_USERNAME", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  database: "spire_dev",
  hostname: System.get_env("DB_HOSTNAME", "localhost"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
