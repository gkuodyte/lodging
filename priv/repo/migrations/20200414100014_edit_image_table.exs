defmodule Lodging.Repo.Migrations.EditImageTable do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :listing_id, references(:listings, type: :uuid)
    end
  end
end
