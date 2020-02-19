defmodule SpireDb.Repo do
  use Ecto.Repo,
    otp_app: :spire_db,
    adapter: Ecto.Adapters.Postgres
end
