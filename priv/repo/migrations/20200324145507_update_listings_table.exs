defmodule Lodging.Repo.Migrations.UpdateListingsTable do
  use Ecto.Migration

  def change do
    alter table("listings") do
    add(:config, :json)
    end
  end
end
