defmodule Mockatron.Guardian do
  use Guardian, otp_app: :mockatron

  alias Mockatron.Auth.User

  def subject_for_token(%User{} = user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = Mockatron.Auth.get_user!(id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
