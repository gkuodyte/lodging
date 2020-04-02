defmodule Lodging.Repo.Migrations.CreateEnquiriesTable do
  use Ecto.Migration

  def up do
    create table("enquiries", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, :uuid
      add :business_id, :uuid
      add :accommodation, :boolean
      add :guests_number, :integer
      add :catering, :boolean
      add :tailorable_menu, :boolean
      add :events, :boolean
      add :comment, :string
      add :date_from, :date
      add :date_to, :date
      add :listing_id, references(:listings, type: :uuid)

      timestamps()
    end
  end

  def down do
    drop table("enquiries")
  end
end
