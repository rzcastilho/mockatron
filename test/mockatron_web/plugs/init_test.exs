defmodule MockatronWeb.InitTest do
  use MockatronWeb.ConnCase, async: true
  alias MockatronWeb.Init

  alias Mockatron.Guardian.Plug
  alias Mockatron.Auth

  @user_valid_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}

  setup do
    {:ok, user} = Auth.create_user(@user_valid_attrs)
    conn = Plug.sign_in(build_conn(), user)
    {:ok, conn: conn}
  end

  test "Init plug with mockatron structure", %{conn: conn} do
    conn = conn
    |> Init.call(%{})
    assert conn.assigns[:mockatron]
  end

end
