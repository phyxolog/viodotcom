defmodule GeoIP.Repo do
  use Ecto.Repo, otp_app: :geoip, adapter: Ecto.Adapters.Postgres
end
