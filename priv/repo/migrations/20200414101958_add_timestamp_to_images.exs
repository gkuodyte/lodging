defmodule Lodging.Repo.Migrations.AddTimestampToImages do
  use Ecto.Migration

  def up do
    alter table(:images) do
      timestamps()
    end
  end

  def down do
    alter table(:images) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
