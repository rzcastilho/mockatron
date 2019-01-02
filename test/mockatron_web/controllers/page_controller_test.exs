defmodule MockatronWeb.PageControllerTest do
  use MockatronWeb.ConnCase

  test "GET /v1/mockatron/ui", %{conn: conn} do
    conn = get conn, "/v1/mockatron/ui"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
