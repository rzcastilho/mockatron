defmodule Mockatron.Email do
  use Bamboo.Phoenix, view: MockatronWeb.EmailView

  def verify_email(email_address, verification_url) do
    new_email()
    |> to(email_address)
    |> from("postmaster@mockatron.io")
    |> subject("Welcome to mockatron.io!!!")
    |> put_html_layout({MockatronWeb.EmailView, "verify_email.html"})
    |> render("verify_email.html",
      email_address: email_address,
      verification_url: verification_url
    )
  end
end
