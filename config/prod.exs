use Mix.Config

config :mockatron, MockatronWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "mockatron.io", port: System.get_env("PORT")],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :logger, level: :info

config :mockatron, Mockatron.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
