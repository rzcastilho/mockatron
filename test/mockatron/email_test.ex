defmodule Mockatron.EmailTest do
  use ExUnit.Case

  alias Mockatron.Email

  test "verify email" do
    email_address = "test@mockatron.io"
    verification_url = "/v1/mockatron/auth/verify?token=LZNItcuvgRf1ouMfJwCMpRhoH+oNH7riSgar3RnIWKONyjDRY/OCGmjiHKYbhMFd"

    email = Email.verify_email(email_address, verification_url)

    assert email.to == email_address
    assert email.html_body =~ verification_url
  end

end
