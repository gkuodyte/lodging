defmodule Lodging.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def up do
    create table("users", primary_key: false) do
      add :username, :string, null: false
      add :name, :string, null: false
      add :lastname, :string, null: false
      add :email_address, :string, null: false
      add :encrypted_password, :string, null: false
      add :over_18, :boolean, default: true
      add :account_type, :string
      add :terms_and_conditions, :boolean, default: true
      add :verified, :boolean, default: false, null: false
      add :id, :uuid, primary_key: true

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email_address])
  end

  def down do
    drop table("users")
  end
end
