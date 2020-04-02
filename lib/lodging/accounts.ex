defmodule Lodging.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  use OK.Pipe
  alias Lodging.Repo
  alias Lodging.Accounts.{User, Business, Listing}

  def change_user(%User{} = user \\ %User{}, %{} = changes) do
    user
    |> User.changeset(changes)
  end

  def create_user(%{} = data) do
    %User{account_type: "user", verified: false, id: Ecto.UUID.generate()}
    |> change_user(data)
    |> Repo.insert()
  end

  def all_user do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user(id) do
    Repo.get(User, id)
    |> case do
      nil -> {:error, id}
      user -> {:ok, user}
    end
  end

  def change_business(%Business{} = business \\ %Business{}, %{} = changes) do
    business
    |> Business.changeset(changes)
  end

  def create_business(%{} = data) do
    %Business{account_type: "business", verified: false, id: Ecto.UUID.generate()}
    |> change_business(data)
    |> Repo.insert()
  end

  def get_business!(id) do
    Repo.get!(Business, id)
    |> preload_listings()
  end

  def preload_listings(business) do
    # Repo.all from b in Business, preload: [:listings]
    Repo.preload business, :listings
  end

  def get_business(id) do
    Repo.get(Business, id)
    |> case do
      nil -> {:error, id}
      business -> {:ok, business}
    end
  end

  #   def get_user_by_email(email) do
  #     Repo.get_by(User, email: email)
  #     |> OK.required(:missing_user)
  #   end

  #   def update_user_info(%User{} = user, attrs) do
  #     user
  #     |> User.user_info_changeset(attrs)
  #     |> Repo.update()
  #   end

  def validate_user(%User{} = user) do
    user
    |> User.verified_changeset(%{verified: true})
    |> Repo.update()
  end

  def validate_business(%Business{} = business) do
    business
    |> Business.verified_changeset(%{verified: true})
    |> Repo.update()
  end

  #   def delete_user(%User{} = user) do
  #     Repo.delete(user)
  #   end

  #   def change_info(%User{} = user, params \\ %{}) do
  #     User.user_info_changeset(user, params)
  #   end

  #   def change_password(%User{} = user, attrs) do
  #     user
  #     |> User.password_changeset(attrs)
  #     |> Repo.update()
  #   end
end
