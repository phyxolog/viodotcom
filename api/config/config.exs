import Config

# Import environment specific config.
import_config "#{config_env()}.exs"

# Import environment specific secret config.
if File.exists?(Path.expand("#{config_env()}.secret.exs", __DIR__)) do
  import_config "#{config_env()}.secret.exs"
end
