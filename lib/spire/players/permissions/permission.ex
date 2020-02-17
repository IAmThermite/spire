defmodule Spire.Players.Permissions.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Players.Player

  schema "permissions" do
    field :can_upload_logs, :boolean, default: true
    field :can_manage_logs, :boolean, default: false
    field :can_run_pipeline, :boolean, default: false
    field :can_manage_players, :boolean, default: false
    field :can_manage_matches, :boolean, default: false
    field :can_manage_leagues, :boolean, default: false
    field :is_super_admin, :boolean, default: false

    belongs_to :player, Player

    timestamps()
  end

  @doc false
  def changeset(permissions, attrs) do
    permissions
    |> cast(attrs, [:can_upload_logs, :can_manage_logs, :can_run_pipeline, :can_manage_players, :can_manage_matches, :can_manage_leagues, :is_super_admin, :player_id])
    |> unique_constraint(:player_id)
    |> validate_required([:player_id])
    |> assoc_constraint(:player)
  end
end
