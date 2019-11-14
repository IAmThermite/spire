defmodule Spire.PlayersMatches.PlayerMatch do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spire.Players.Player
  alias Spire.Leagues.Matches.Match

  @primary_key false
  schema "players_matches" do
    belongs_to(:player, Player, primary_key: true)
    belongs_to(:match, Match, primary_key: true)

    timestamps()
  end

  @doc false
  def changeset(player_match, attrs) do
    player_match
    |> cast(attrs, [:player, :match])
    |> validate_required([:player_id, :match_id])
  end
end
