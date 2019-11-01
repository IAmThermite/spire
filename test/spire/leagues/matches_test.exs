defmodule Spire.Leagues.MatchesTest do
  use Spire.DataCase

  alias Spire.Leagues.Matches

  describe "matches" do
    alias Spire.Leagues.Matches.Match

    @valid_attrs %{date: ~D[2010-04-17], link: "some link", title: "some title", tournament: 42}
    @update_attrs %{date: ~D[2011-05-18], link: "some updated link", title: "some updated title", tournament: 43}
    @invalid_attrs %{date: nil, link: nil, title: nil, tournament: nil}

    def match_fixture(attrs \\ %{}) do
      {:ok, match} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Matches.create_match()

      match
    end

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Matches.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Matches.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      assert {:ok, %Match{} = match} = Matches.create_match(@valid_attrs)
      assert match.date == ~D[2010-04-17]
      assert match.link == "some link"
      assert match.title == "some title"
      assert match.tournament == 42
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      assert {:ok, %Match{} = match} = Matches.update_match(match, @update_attrs)
      assert match.date == ~D[2011-05-18]
      assert match.link == "some updated link"
      assert match.title == "some updated title"
      assert match.tournament == 43
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Matches.update_match(match, @invalid_attrs)
      assert match == Matches.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Matches.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Matches.change_match(match)
    end
  end
end
