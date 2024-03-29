defmodule Spire.SpireDB.Players.Permissions do
  @moduledoc """
  The Leagues context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo

  alias Spire.SpireDB.Players.Permissions.Permission

  def get_permissions_for_player(player_id) do
    results = Repo.all(from(p in Permission, where: p.player_id == ^player_id))

    case results do
      [permission | _tail] ->
        permission

      _ ->
        nil
    end
  end

  def create_or_update_permissions(attrs) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :player_id]},
      conflict_target: :player_id
    )
  end

  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  def change_permission(%Permission{} = permission) do
    Permission.changeset(permission, %{})
  end

  def change_permission(_) do
    Permission.changeset(%Permission{}, %{})
  end
end
