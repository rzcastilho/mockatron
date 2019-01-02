defmodule MockatronWeb.UserControllerTest do
  use MockatronWeb.ConnCase

  alias Mockatron.Auth

  @create_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}
  @invalid_attrs %{email: nil, password_hash: nil, verified: nil}

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert %{"jwt" => jwt} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "sign in user" do
    setup [:create_user]

    test "sign in chosen user", %{conn: conn} do
      conn = post conn, user_path(conn, :sign_in), @create_attrs
      assert %{"jwt" => jwt} = json_response(conn, 200)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
