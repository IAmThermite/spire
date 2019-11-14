defmodule Spire.PlayersMatchesTest do
  use Spire.DataCase

  alias Spire.PlayersMatches

  describe "players_matches" do
    alias Spire.PlayersMatches.PlayerMatch

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def player_match_fixture(attrs \\ %{}) do
      {:ok, player_match} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PlayersMatches.create_player_match()

      player_match
    end

    test "list_players_matches/0 returns all players_matches" do
      player_match = player_match_fixture()
      assert PlayersMatches.list_players_matches() == [player_match]
    end

    test "get_player_match!/1 returns the player_match with given id" do
      player_match = player_match_fixture()
      assert PlayersMatches.get_player_match!(player_match.id) == player_match
    end

    test "create_player_match/1 with valid data creates a player_match" do
      assert {:ok, %PlayerMatch{} = player_match} = PlayersMatches.create_player_match(@valid_attrs)
    end

    test "create_player_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PlayersMatches.create_player_match(@invalid_attrs)
    end

    test "update_player_match/2 with valid data updates the player_match" do
      player_match = player_match_fixture()
      assert {:ok, %PlayerMatch{} = player_match} = PlayersMatches.update_player_match(player_match, @update_attrs)
    end

    test "update_player_match/2 with invalid data returns error changeset" do
      player_match = player_match_fixture()
      assert {:error, %Ecto.Changeset{}} = PlayersMatches.update_player_match(player_match, @invalid_attrs)
      assert player_match == PlayersMatches.get_player_match!(player_match.id)
    end

    test "delete_player_match/1 deletes the player_match" do
      player_match = player_match_fixture()
      assert {:ok, %PlayerMatch{}} = PlayersMatches.delete_player_match(player_match)
      assert_raise Ecto.NoResultsError, fn -> PlayersMatches.get_player_match!(player_match.id) end
    end

    test "change_player_match/1 returns a player_match changeset" do
      player_match = player_match_fixture()
      assert %Ecto.Changeset{} = PlayersMatches.change_player_match(player_match)
    end
  end
end
