import Config

# Configure your database
config :geoip, GeoIP.Repo,
  username: "postgres",
  password: "postgres",
  database: "geoip_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
