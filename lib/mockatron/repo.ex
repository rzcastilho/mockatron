defmodule Mockatron.Repo do
  use Ecto.Repo,
    otp_app: :mockatron,
    adapter: Ecto.Adapters.Postgres
end
