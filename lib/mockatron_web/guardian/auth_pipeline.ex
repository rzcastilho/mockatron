defmodule MockatronWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :mockatron,
                              module: Mockatron.Guardian,
                              error_handler: MockatronWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end