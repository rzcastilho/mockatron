# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mockatron,
  ecto_repos: [Mockatron.Repo]

# Configures the endpoint
config :mockatron, MockatronWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R9znm+thCDifA9vfwCXhclwZlGtNnsFBgUJurl/m83Fc+Oav+CAoF6sEjYV8joQP",
  render_errors: [view: MockatronWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mockatron.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :mockatron, Mockatron.Guardian,
  issuer: "mockatron",
  secret_key: "o7rkzJ9H28eafh2jD4LzAzX01QQvlxl2xU0SvRsTM8hFMO5JvemVb9H0uzsTf7/E"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
