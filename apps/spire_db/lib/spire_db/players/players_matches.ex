defmodule Spire.SpireDB.Players.PlayersMatches do
  use Ecto.Schema

  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Leagues.Matches.Match

  schema "players_matches" do
    belongs_to :player, Player
    belongs_to :match, Match

    timestamps()
  end
end
