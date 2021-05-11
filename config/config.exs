# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mockatron,
  ecto_repos: [Mockatron.Repo]

# Configures the endpoint
config :mockatron, MockatronWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RkKJhaPjmIYT7w1yysXlv8BsGc/htJdfWr8XyIQMU8OH9hPqD4U8mWp6EQDPZL7k",
  render_errors: [view: MockatronWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mockatron.PubSub,
  live_view: [signing_salt: "Kdu9aK/a"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mockatron, Mockatron.Guardian,
  issuer: "mockatron",
  secret_key: "o7rkzJ9H28eafh2jD4LzAzX01QQvlxl2xU0SvRsTM8hFMO5JvemVb9H0uzsTf7/E"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
