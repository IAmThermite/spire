defmodule Spire.SpireDB.Players.PlayersLogs do
  use Ecto.Schema

  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Logs.Log

  schema "players_logs" do
    belongs_to :player, Player
    belongs_to :log, Log

    timestamps()
  end
end
