import Config

config :geoip, ecto_repos: [GeoIP.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Import environment specific secret config.
if File.exists?(Path.expand("#{config_env()}.secret.exs", __DIR__)) do
  import_config("#{config_env()}.secret.exs")
end
