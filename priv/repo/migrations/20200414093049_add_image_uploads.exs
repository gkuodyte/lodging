defmodule Lodging.Repo.Migrations.AddImageUploads do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :image_data, :binary
      add :image_name, :string
      add :image_type, :string, size: 20
    end
  end
end
