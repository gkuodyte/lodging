defmodule Lodging.TokenTest do
  use Lodging.DataCase

  alias Lodging.{Accounts, Token}

  @user1_id Ecto.UUID.generate()

  @valid_attrs %{
    id: @user1_id,
    username: "TestUser",
    name: "Test Name",
    lastname: "Surname",
    email_address: "test_email@test.com",
    password: "TestingPass123",
    password_confirmation: "TestingPass123",
    over_18: true,
    account_type: "user",
    terms_and_conditions: true,
    verified: false
  }

  def user_account(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_user()

    user
  end

  def unverified_user_account(_) do
    user = user_account()
    {:ok, user: user}
  end

  describe "vali user verification token" do
    setup [:unverified_user_account]

    test "generate a verification token that will verify users account", %{user: user} do
      token = Token.generate_new_account_token(user)
      {:ok, user_id} = Token.verify_new_account_token(token)
      assert user_id == user.id
    end
  end
end
