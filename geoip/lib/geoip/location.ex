defmodule GeoIP.Location do
  @moduledoc """
  Latitude & longitude could be zero (Null Island).
  """

  use Ecto.Schema

  alias GeoIP.Location

  import Ecto.Changeset

  @type t() :: %__MODULE__{
          ip_address: EctoNetwork.INET,
          country_code: String.t(),
          country: String.t(),
          city: String.t(),
          latitude: float(),
          longitude: float(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:ip_address, EctoNetwork.INET, autogenerate: false}

  @permitted ~w(ip_address country_code country city latitude longitude)a

  schema "locations" do
    field(:country_code, :string)
    field(:country, :string)
    field(:city, :string)
    field(:latitude, :float)
    field(:longitude, :float)

    timestamps()
  end

  def changeset(%Location{} = location, attrs \\ %{}) do
    location
    |> cast(attrs, @permitted)
    |> validate_required(@permitted)
    |> validate_length(:country_code, is: 2)
    |> validate_change(:country_code, :format, fn _, value ->
      if String.upcase(value) == value,
        do: [],
        else: [country_code: "should be in uppercase format"]
    end)
  end
end
