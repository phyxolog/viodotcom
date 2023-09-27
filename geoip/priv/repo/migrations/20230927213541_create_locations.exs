defmodule GeoIP.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations, primary_key: false) do
      add :ip_address, :inet, primary_key: true
      add :country_code, :string, null: false
      add :country, :string, null: false
      add :city, :string, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false

      timestamps()
    end
  end
end
