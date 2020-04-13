defmodule Lodging.Repo.Migrations.AddListingIdToUploads do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :listing_id, references(:listings, type: :uuid)
    end
  end
end
