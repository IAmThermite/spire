defmodule Spire.SpireDB.Repo.Migrations.AddConstraintsToMatches do
  use Ecto.Migration

  def change do
    create unique_index("matches", [:title])
    create unique_index("matches", [:link])
  end
end
