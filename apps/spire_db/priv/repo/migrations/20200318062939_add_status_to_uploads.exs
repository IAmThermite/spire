defmodule Spire.SpireDB.Repo.Migrations.AddStatusToUploads do
  use Ecto.Migration

  def change do
    alter table("log_upload") do
      remove :approved
      add :status, :string, null: false, default: "PENDING"
    end
  end
end
