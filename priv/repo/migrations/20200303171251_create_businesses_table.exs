defmodule Lodging.Repo.Migrations.CreateBusinessesTable do
  use Ecto.Migration

  def up do
    create table(:businesses, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :lastname, :string, null: false
      add :username, :string, null: false
      add :encrypted_password, :string, null: false
      add :email_address, :string, null: false
      add :business_name, :string, null: false
      add :business_address, :string, null: false
      add :business_number, :string
      add :accommodation, :boolean
      add :catering, :boolean
      add :events, :boolean
      add :account_type, :string
      add :terms_and_conditions, :boolean, default: false
      add :verified, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:businesses, [:username])
    create unique_index(:businesses, [:email_address])
  end

  def down do
    drop table("businesses")
  end
end
