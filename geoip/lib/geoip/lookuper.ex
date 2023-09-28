defmodule GeoIP.Lookuper do
  @moduledoc false

  alias GeoIP.Location
  alias GeoIP.Repo

  @spec lookup(String.t()) :: GeoIP.LookupResponse.t() | nil
  def lookup(ip_address) do
    Location
    |> Repo.get_by(ip_address: ip_address)
    |> lookup_response_from_location()
  end

  defp lookup_response_from_location(%GeoIP.Location{} = location) do
    %GeoIP.LookupResponse{
      ip_address: EctoNetwork.INET.decode(location.ip_address),
      country_code: location.country_code,
      country: location.country,
      city: location.city,
      latitude: location.latitude,
      longitude: location.longitude
    }
  end

  defp lookup_response_from_location(_) do
    nil
  end
end
