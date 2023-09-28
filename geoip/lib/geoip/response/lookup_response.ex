defmodule GeoIP.LookupResponse do
  @moduledoc false

  @derive Jason.Encoder

  @type t() :: %GeoIP.LookupResponse{
          ip_address: String.t(),
          country_code: String.t(),
          country: String.t(),
          city: String.t(),
          latitude: float(),
          longitude: float()
        }

  defstruct [:ip_address, :country_code, :country, :city, :latitude, :longitude]
end
