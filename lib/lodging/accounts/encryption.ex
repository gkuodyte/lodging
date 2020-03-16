defmodule Lodging.Accounts.Encryption do
  @moduledoc """
  User password ancryption module.
  """
  alias Lodging.Accounts.{User, Business}

  @doc """
  Given a password, hash it, using a salt.
  """
  def hash_password(password) do
    Bcrypt.hash_pwd_salt(password)
  end

  @doc """
  Given a user and a string, check if the string is the password for the user account.

  ## example
    validate_password(:a_valid_user, :valid_password)
    {:ok, :a_valid_user}

    validate_password(:a_valid_user, :invalid_password)
    {:error, "invalid password"}
  """
  def validate_user_password(%User{} = user, password), do: Bcrypt.check_pass(user, password)

  def validate_business_password(%Business{} = business, password),
    do: Bcrypt.check_pass(business, password)

  @doc """
  Checks if a password is valid for a given user.
  """
  def valid_user_password?(user, password) do
    case validate_user_password(user, password) do
      {:ok, _user} -> true
      {:error, _user} -> false
    end
  end

  def valid_business_password?(business, password) do
    case validate_business_password(business, password) do
      {:ok, _business} -> true
      {:error, _business} -> false
    end
  end
end
