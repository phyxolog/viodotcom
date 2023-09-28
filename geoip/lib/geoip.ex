defmodule GeoIP do
  @moduledoc false

  @spec lookup(String.t()) :: GeoIP.LookupResponse.t() | nil
  def lookup(ip_address) do
    GeoIP.Lookuper.lookup(ip_address)
  end

  @spec import!(String.t()) :: GeoIP.ImportResponse.t()
  def import!(path) do
    GeoIP.Importer.import!(path)
  end
end
