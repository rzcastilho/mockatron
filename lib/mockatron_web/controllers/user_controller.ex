defmodule MockatronWeb.UserController do
  use MockatronWeb, :controller

  alias Mockatron.Auth
  alias Mockatron.Auth.User

  alias Mockatron.Guardian

  action_fallback MockatronWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Auth.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn |> render("jwt.json", jwt: token)
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("jwt.json", jwt: token)
      error ->
        error
    end
  end


end
