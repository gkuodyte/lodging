defmodule Lodging.Repo.Migrations.UpdateEnquiriesTableMeals do
  use Ecto.Migration

  def change do
    alter table("enquiries") do
      add(:meals_number, :integer)
    end
  end
end
