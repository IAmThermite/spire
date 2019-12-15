defmodule Spire.Repo.Migrations.CreateLogUpload do
  use Ecto.Migration

  def change do
    create table(:log_upload) do
      add :approved, :boolean, default: false
      add :processed, :boolean, default: false
      add :log_id, references(:logs, on_delete: :delete_all)
      add :uploaded_by, references(:players, on_delete: :delete_all)

      timestamps()
    end
    create(index(:log_upload, [:log_id]))
    create(index(:log_upload, [:uploaded_by]))

    create unique_index(:log_upload, [:uploaded_by, :log_id], name: :uploader_log_index)
  end
end
