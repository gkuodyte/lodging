defmodule Lodging.Repo.Migrations.AddListingsTable do
  use Ecto.Migration

  def up do
    create table("listings", primary_key: false) do
      add :accommodation, :boolean
      add :property_type, :string
      add :rooms_number, :integer
      add :rooms_type, :string
      add :guests_number, :integer
      add :country, :string
      add :street_address, :string
      add :street_address2, :string
      add :city, :string
      add :postcode, :string
      add :night_price, :integer
      add :catering, :boolean
      add :tailorable_menu, :boolean
      add :meals_number, :integer
      add :meals_price_range, :integer
      add :events, :boolean
      add :events_type, :string
      add :contact_number, :string
      add :id, :uuid, primary_key: true
      add :business_id, references(:businesses, type: :uuid)

      timestamps()
    end
  end

  def down do
    drop table("listings")
  end
end
