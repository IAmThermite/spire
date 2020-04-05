defmodule Spire.SpireDB.Repo.Migrations.AlterLogUploadTableName do
  use Ecto.Migration

  def change do
    rename table("log_upload"), to: table("uploads")
  end
end
