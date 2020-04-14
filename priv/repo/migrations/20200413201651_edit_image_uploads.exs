defmodule Lodging.Repo.Migrations.EditImageUploads do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :image_data, :binary
    end
  end
end
