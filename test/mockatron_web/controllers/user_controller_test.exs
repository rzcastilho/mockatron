defmodule MockatronWeb.UserControllerTest do
  use MockatronWeb.ConnCase

  alias Mockatron.Auth
  alias Mockatron.Auth.User
  alias Mockatron.Token

  @create_attrs %{
    email: "test@mockatron.io",
    password: "Welcome1",
    password_confirmation: "Welcome1"
  }
  @invalid_attrs %{email: nil, password_hash: nil}

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, Routes.user_path(conn, :create), user: @create_attrs
      assert response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "verify email" do
    setup [:create_user]

    test "email verified", %{conn: conn, token: token} do
      conn = get(conn, Routes.user_path(conn, :verify_email, token: token))
      assert response(conn, 204)
    end

    test "invalid account verification token", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :verify_email, token: "invalid_token"))
      assert %{"code" => 4, "error" => "Unauthorized"} = json_response(conn, 401)
    end

    test "bad request", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :verify_email))
      assert %{"code" => 99, "error" => "Bad Request"} = json_response(conn, 400)
    end
  end

  describe "resend token" do
    setup [:create_user]

    test "token resended", %{conn: conn, user: %User{email: email}} do
      conn = get(conn, Routes.user_path(conn, :resend_token, email: email))
      assert response(conn, 204)
    end

    test "unauthorized email not found", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :resend_token, email: "notfound@mockatron.io"))
      assert %{"code" => 1, "error" => "Unauthorized"} = json_response(conn, 401)
    end

    test "bad request", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :resend_token))
      assert %{"code" => 99, "error" => "Bad Request"} = json_response(conn, 400)
    end
  end

  describe "sign in user" do
    setup [:create_user]

    test "chosen user", %{conn: conn, token: token} do
      get(conn, Routes.user_path(conn, :verify_email, token: token))
      conn = post conn, Routes.user_path(conn, :sign_in), @create_attrs
      assert %{"jwt" => _jwt} = json_response(conn, 200)
    end

    test "unauthorized email not found", %{conn: conn} do
      conn =
        post conn,
             Routes.user_path(conn, :sign_in),
             @create_attrs |> Map.put(:email, "notfound@mockatron.io")

      assert %{"code" => 1, "error" => "Unauthorized"} = json_response(conn, 401)
    end

    test "unauthorized invalid password", %{conn: conn, token: token} do
      get(conn, Routes.user_path(conn, :verify_email, token: token))

      conn =
        post conn,
             Routes.user_path(conn, :sign_in),
             @create_attrs |> Map.put(:password, "welcome1")

      assert %{"code" => 2, "error" => "Unauthorized"} = json_response(conn, 401)
    end

    test "unauthorized email not verified", %{conn: conn} do
      conn = post conn, Routes.user_path(conn, :sign_in), @create_attrs
      assert %{"code" => 3, "error" => "Unauthorized"} = json_response(conn, 401)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    token = Token.generate_new_account_token(user)
    {:ok, user: user, token: token}
  end
end
