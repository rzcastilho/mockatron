defmodule MockatronWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MockatronWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(MockatronWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(MockatronWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :email_not_found}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{code: 1, error: "Unauthorized", message: "Email not found"})
  end

  def call(conn, {:error, :invalid_password}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{code: 2, error: "Unauthorized", message: "Invalid password"})
  end

  def call(conn, {:error, :email_not_verified}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{code: 3, error: "Unauthorized", message: "Email address not verified"})
  end

  def call(conn, {:error, :invalid_account_verification_token}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{code: 4, error: "Unauthorized", message: "Account verification token is invalid"})
  end

  def call(conn, {:error, :bad_request, message}) do
    conn
    |> put_status(:bad_request)
    |> json(%{code: 99, error: "Bad Request", message: message})
  end

end
