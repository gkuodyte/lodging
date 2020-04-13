defmodule Lodging.AccountsTest do
  use Lodging.DataCase

  alias Lodging.Accounts
  alias Lodging.Accounts.User

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
    verified: true
  }

  @invalid_attrs %{email_address: nil, name: nil, username: nil}

  def user_account(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_user()

    user
  end

  defp remove_virtual_fields(user) do
    %{user | password: nil, password_confirmation: nil}
  end

  test "all_user/0 returns all users" do
    user =
      user_account()
      |> remove_virtual_fields()

    assert Accounts.all_user() == [user]
  end

  test "get_user!/1 gets the correct user with the provided user id" do
    user =
      user_account()
      |> remove_virtual_fields()

    assert Accounts.get_user!(user.id) == user
  end

  test "create_user/1 with invalid parameters returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  test "change_user/1 returns a user changeset" do
    user = user_account()
    assert %Ecto.Changeset{} = Accounts.change_user(user, %{})
  end
end
