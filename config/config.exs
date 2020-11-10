# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lodging,
  ecto_repos: [Lodging.Repo]

config :lodging, Lodging.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.sendgrid.net",
  port: 587,
  username: " ",
  password: " ",
  # can be `:always` or `:never`
  tls: :never,
  # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  # can be `true`
  ssl: false,
  retries: 1,
  no_mx_lookups: true,
  auth: :if_available

# Configures the endpoint
config :lodging, LodgingWeb.Endpoint,
  url: [host: "localhost"],
  live_view: [
    signing_salt: "n3jhdkt9pAbeg1erAu/PV4Dn1f+QsZJe"
  ],
  secret_key_base: " ",
  render_errors: [view: LodgingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Lodging.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :lodging,
local_url: "localhost:4000"
