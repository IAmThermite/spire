use Mix.Config

# Configure your database
config :spire_db, Spire.SpireDB.Repo,
  username: "postgres",
  password: "postgres",
  database: "spire_db_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
config :schemas, Schemas.Repo,
  username: "postgres",
  password: "postgres",
  database: "schemas_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
config :spire_schemas, Spire.SpireDB.Repo,
  username: "postgres",
  password: "postgres",
  database: "spire_schemas_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
