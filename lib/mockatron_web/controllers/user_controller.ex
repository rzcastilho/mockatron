defmodule MockatronWeb.UserController do
  use MockatronWeb, :controller

  alias Mockatron.Email
  alias Mockatron.Mailer

  alias Mockatron.Auth
  alias Mockatron.Auth.User
  alias Mockatron.Token

  action_fallback MockatronWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Auth.create_user(user_params) do
      token = Token.generate_new_account_token(user)
      verification_url = Routes.user_path(conn, :verify_email, token: token)

      Email.verify_email(user.email, verification_url)
      |> Mailer.deliver_later()

      conn
      |> send_resp(:created, "")
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

  def verify_email(conn, %{"token" => token}) do
    with {:ok, user_id} <- Token.verify_new_account_token(token),
         {:ok, %User{verified: false} = user} <- Auth.get_user(user_id) do
      Auth.mark_as_verified(user)

      conn
      |> send_resp(:no_content, "")
    else
      _ -> {:error, :invalid_account_verification_token}
    end
  end

  def verify_email(_, _), do: {:error, :bad_request, "Token not provided"}

  def resend_token(conn, %{"email" => email}) do
    case Auth.get_by_email(email) do
      {:ok, %User{} = user} ->
        token = Token.generate_new_account_token(user)
        verification_url = Routes.user_path(conn, :verify_email, token: token)

        Email.verify_email(user.email, verification_url)
        |> Mailer.deliver_later()

        conn
        |> send_resp(:no_content, "")

      _ ->
        {:error, :email_not_found}
    end
  end

  def resend_token(_, _), do: {:error, :bad_request, "Email not provided"}
end
