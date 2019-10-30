defmodule Spire.Repo do
  use Ecto.Repo,
    otp_app: :spire,
    adapter: Ecto.Adapters.Postgres
end
