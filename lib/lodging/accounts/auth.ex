defmodule Lodging.Accounts.Auth do
  @moduledoc """
  Handles user authentication for logging in and checking if a user is logged in.
  """

  alias Lodging.Accounts.{User, Business, Encryption}
  alias Lodging.Repo

  def login_user(params) do
    Repo.get_by(User, username: String.downcase(params["username"]))
    |> case do
      nil ->
        {:error, :wrong_table}

      user ->
        {:ok, user}

        case authenticate_user(user, params["password"]) do
          true -> {:ok, user}
          _ -> {:error, "Invalid password"}
        end
    end
  end

  #  Checks the password against the hash in the database
  defp authenticate_user(nil, _password), do: nil

  defp authenticate_user(user, password) do
    case Encryption.validate_user_password(user, password) do
      {:ok, authenticated_user} ->
        authenticated_user.username == user.username

      _ ->
        nil
    end
  end

  def login_business(params) do
    business = Repo.get_by(Business, username: String.downcase(params["username"]))

    case authenticate_business(business, params["password"]) do
      true -> {:ok, business}
      _ -> {:error, "Invalid password"}
    end
  end

  defp authenticate_business(nil, _password), do: nil

  defp authenticate_business(business, password) do
    case Encryption.validate_business_password(business, password) do
      {:ok, authenticated_business} ->
        authenticated_business.username == business.username

      _ ->
        nil
    end
  end

  def signed_in?(conn),
    do: !!Plug.Conn.get_session(conn, :current_account_id)
end
