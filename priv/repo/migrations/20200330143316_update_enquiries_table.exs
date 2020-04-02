defmodule Lodging.Repo.Migrations.UpdateEnquiriesTable do
  use Ecto.Migration

  def change do
    alter table("enquiries") do
      add(:contact_number, :string)
    end
  end
end
