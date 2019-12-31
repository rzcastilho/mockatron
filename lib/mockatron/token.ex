defmodule Mockatron.Token do
  alias Mockatron.Auth.User

  @account_verification_salt "account verification salt"

  def generate_new_account_token(%User{id: user_id}) do
    Phoenix.Token.sign(MockatronWeb.Endpoint, @account_verification_salt, user_id)
  end

  def verify_new_account_token(token) do
    max_age = 86_400 # a day
    Phoenix.Token.verify(MockatronWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end

end
