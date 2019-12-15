defmodule Spire.PlayersTest do
  use Spire.DataCase

  alias Spire.Players

  describe "players" do
    alias Spire.Players.Player

    @valid_attrs %{alias: "some alias", primary_league: 42, steamid64: "some steamid64", steamid: "some steamid"}
    @update_attrs %{alias: "some updated alias", primary_league: 43, steamid64: "some updated steamid64", steamid: "some updated steamid"}
    @invalid_attrs %{alias: nil, primary_league: nil, steamid64: nil, steamid: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Players.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Players.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Players.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Players.create_player(@valid_attrs)
      assert player.alias == "some alias"
      assert player.primary_league == 42
      assert player.steamid64 == "some steamid64"
      assert player.steamid == "some steamid"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Players.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Players.update_player(player, @update_attrs)
      assert player.alias == "some updated alias"
      assert player.primary_league == 43
      assert player.steamid64 == "some updated steamid64"
      assert player.steamid == "some updated steamid"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.update_player(player, @invalid_attrs)
      assert player == Players.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Players.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Players.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Players.change_player(player)
    end
  end
end
