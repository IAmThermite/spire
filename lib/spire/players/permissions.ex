defmodule Spire.Players.Permissions do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Players.Player

  schema "permissions" do
    field :can_upload_logs, :boolean
    field :can_add_matches, :boolean
    field :can_approve_logs, :boolean
    field :can_manage_logs, :boolean
    field :can_run_pipeline, :boolean
    field :can_manage_matches, :boolean
    field :can_manage_leagues, :boolean
    field :is_super_admin, :boolean

    belongs_to :player, Player

    timestamps()
  end

  @doc false
  def changeset(permissions, attrs) do
    permissions
    |> cast(attrs, [:can_upload_logs, :can_add_matches, :can_approve_logs, :can_manage_leagues, :can_run_pipeline, :can_manage_matches, :can_manage_leagues, :is_super_admin, :player_id])
    |> unique_constraint(:player_id)
    |> validate_required([:player_id])
    |> assoc_constraint(:player)
  end
end
