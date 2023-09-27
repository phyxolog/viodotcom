defmodule GeoIP do
  @moduledoc false

  alias GeoIP.Location
  alias GeoIP.Repo

  @batch_size 1000

  defmodule LookupResponse do
    @moduledoc false

    @derive Jason.Encoder

    @type t() :: %LookupResponse{
            ip_address: String.t(),
            country_code: String.t(),
            country: String.t(),
            city: String.t(),
            latitude: float(),
            longitude: float()
          }

    defstruct [:ip_address, :country_code, :country, :city, :latitude, :longitude]
  end

  defmodule ImportResponse do
    @moduledoc false

    @derive Jason.Encoder

    @type t() :: %ImportResponse{
            total: non_neg_integer(),
            imported: non_neg_integer(),
            discarded: non_neg_integer()
          }

    defstruct [:total, :imported, :discarded]
  end

  @spec lookup(String.t()) :: LookupResponse.t() | nil
  def lookup(ip_address) do
    Location
    |> Repo.get_by(ip_address: ip_address)
    |> lookup_response_from_location()
  end

  @spec import!(String.t()) :: ImportResponse.t()
  def import!(path) do
    initial_stream =
      path
      |> File.stream!()
      |> NimbleCSV.RFC4180.parse_stream()

    transform_stream =
      initial_stream
      |> Flow.from_enumerable()
      |> Flow.map(&build_changeset/1)
      |> Flow.filter(fn %Ecto.Changeset{} = changeset -> changeset.valid? end)
      |> Flow.map(fn %Ecto.Changeset{} = changeset ->
        changeset
        |> Ecto.Changeset.apply_changes()
        |> Map.from_struct()
        |> Map.delete(:__meta__)
        |> populate_timestamps()
      end)
      |> Stream.uniq_by(& &1.ip_address)
      |> Stream.chunk_every(@batch_size)

    imported =
      Enum.reduce(transform_stream, 0, fn chunk, acc ->
        {_inserted, _} =
          GeoIP.Repo.insert_all(
            Location,
            chunk,
            on_conflict: {:replace_all_except, [:inserted_at]},
            conflict_target: :ip_address,
            log: false
          )

        length(chunk) + acc
      end)

    total = Enum.count(initial_stream)

    %ImportResponse{
      total: total,
      imported: imported,
      discarded: total - imported
    }
  end

  defp populate_timestamps(location) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    location
    |> Map.put(:inserted_at, now)
    |> Map.put(:updated_at, now)
  end

  defp build_changeset([
         ip_address,
         country_code,
         country,
         city,
         latitude,
         longitude,
         _mystery_code
       ]) do
    Location.changeset(%Location{}, %{
      ip_address: ip_address,
      country_code: country_code,
      country: country,
      city: city,
      latitude: latitude,
      longitude: longitude
    })
  end

  defp lookup_response_from_location(%GeoIP.Location{} = location) do
    %LookupResponse{
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
