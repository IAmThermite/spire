defmodule SpireWeb.LeagueControllerTest do
  use SpireWeb.ConnCase

  alias Spire.Leagues

  @create_attrs %{main: true, name: "some name", website: "some website"}
  @update_attrs %{main: false, name: "some updated name", website: "some updated website"}
  @invalid_attrs %{main: nil, name: nil, website: nil}

  def fixture(:league) do
    {:ok, league} = Leagues.create_league(@create_attrs)
    league
  end

  describe "index" do
    test "lists all leagues", %{conn: conn} do
      conn = get(conn, Routes.league_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Leagues"
    end
  end

  describe "new league" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.league_path(conn, :new))
      assert html_response(conn, 200) =~ "New League"
    end
  end

  describe "create league" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.league_path(conn, :create), league: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.league_path(conn, :show, id)

      conn = get(conn, Routes.league_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show League"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.league_path(conn, :create), league: @invalid_attrs)
      assert html_response(conn, 200) =~ "New League"
    end
  end

  describe "edit league" do
    setup [:create_league]

    test "renders form for editing chosen league", %{conn: conn, league: league} do
      conn = get(conn, Routes.league_path(conn, :edit, league))
      assert html_response(conn, 200) =~ "Edit League"
    end
  end

  describe "update league" do
    setup [:create_league]

    test "redirects when data is valid", %{conn: conn, league: league} do
      conn = put(conn, Routes.league_path(conn, :update, league), league: @update_attrs)
      assert redirected_to(conn) == Routes.league_path(conn, :show, league)

      conn = get(conn, Routes.league_path(conn, :show, league))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, league: league} do
      conn = put(conn, Routes.league_path(conn, :update, league), league: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit League"
    end
  end

  describe "delete league" do
    setup [:create_league]

    test "deletes chosen league", %{conn: conn, league: league} do
      conn = delete(conn, Routes.league_path(conn, :delete, league))
      assert redirected_to(conn) == Routes.league_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.league_path(conn, :show, league))
      end
    end
  end

  defp create_league(_) do
    league = fixture(:league)
    {:ok, league: league}
  end
end
