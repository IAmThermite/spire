use Mix.Config

# Configure your database
config :spire_db, Spire.SpireDB.Repo,
  username: "postgres",
  password: "postgres",
  database: "spire_db_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
