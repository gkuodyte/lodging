defmodule Lodging.Repo.Migrations.UpdateListingsTableWithName do
  use Ecto.Migration

  def change do
    alter table("listings") do
      add(:title, :string)
    end
  end
end
