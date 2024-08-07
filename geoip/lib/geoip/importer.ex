defmodule GeoIP.Importer do
  @moduledoc false

  alias GeoIP.Location
  alias GeoIP.Repo

  @batch_size 1000

  @spec import(String.t()) :: {:ok, GeoIP.ImportResponse.t()} | {:error, :enoent}
  def import(path) do
    case File.exists?(path) do
      true ->
        {usecs, %GeoIP.ImportResponse{} = response} = :timer.tc(&import!/1, [path])
        elapsed_ms = System.convert_time_unit(usecs, :microsecond, :millisecond)

        {:ok, %GeoIP.ImportResponse{response | elapsed_ms: elapsed_ms}}

      _ ->
        {:error, :enoent}
    end
  end

  defp import!(path) do
    initial_stream =
      path
      |> File.stream!()
      |> NimbleCSV.RFC4180.parse_stream()

    imported =
      initial_stream
      |> process_stream()
      |> make_chunks()
      |> insert_chunks()

    total = Enum.count(initial_stream)

    %GeoIP.ImportResponse{
      total: total,
      imported: imported,
      discarded: total - imported
    }
  end

  defp process_stream(stream) do
    stream
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
  end

  defp make_chunks(stream) do
    Stream.chunk_every(stream, @batch_size)
  end

  defp insert_chunks(stream) do
    Enum.reduce(stream, 0, fn chunk, acc ->
      {_inserted, _} =
        Repo.insert_all(
          Location,
          chunk,
          on_conflict: {:replace_all_except, [:inserted_at]},
          conflict_target: :ip_address,
          log: false
        )

      length(chunk) + acc
    end)
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
end
