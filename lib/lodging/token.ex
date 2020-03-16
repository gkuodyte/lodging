defmodule Lodging.Token do
  @moduledoc """
  Handles creating and validating tokens.
  """

  alias Lodging.Accounts.{User, Business}

  @account_verification_salt "Salt and pepper!"
  @business_verification_salt "New Salt 4 businesS!"
  @set_new_password_salt "add lost of 5a1t"

  def generate_new_account_token(%User{id: user_id}) do
    Phoenix.Token.sign(LodgingWeb.Endpoint, @account_verification_salt, user_id)
  end

  def verify_new_account_token(token) do
    # tokens that are older than a day should be invalid
    max_age = 86_400
    Phoenix.Token.verify(LodgingWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end

  def generate_new_business_token(%Business{id: user_id}) do
    Phoenix.Token.sign(LodgingWeb.Endpoint, @business_verification_salt, user_id)
  end

  def verify_new_business_token(token) do
    # tokens that are older than a day should be invalid
    max_age = 86_400

    Phoenix.Token.verify(LodgingWeb.Endpoint, @business_verification_salt, token, max_age: max_age)
  end

  def generate_new_password_token(%User{id: user_id}) do
    Phoenix.Token.sign(LodgingWeb.Endpoint, @set_new_password_salt, user_id)
  end

  def set_new_password_token(token) do
    # tokens that are older than 30 minutes should be invalid
    max_age = 1_800
    Phoenix.Token.verify(LodgingWeb.Endpoint, @set_new_password_salt, token, max_age: max_age)
  end
end
