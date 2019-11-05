defmodule SpireWeb.PageControllerTest do
  use SpireWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to spire"
  end
end
