defmodule LodgingWeb.AccountControllerTest do
  use LodgingWeb.ConnCase

  alias Lodging.{Accounts, Repo, Test, Token}

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

  @unverified_valid_attrs %{
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

  @encryption Application.get_env(:lodging, :password_encryption)
  @extra_valid_password "Very0vert0pPa$$word"
  @valid_name "Firstname Surname"
  @invalid_name "invalid"
  @invalid_email "invalid"

  def user_account(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_user()

    {:ok, user: user}
  end

  def unverified_user_account(attrs \\ %{}) do
    {:ok, user} =
    attrs
    |> Enum.into(@unverified_valid_attrs)
    |> Accounts.create_user()

  {:ok, user: user}
  end

  describe "Create new user - " do
    test "adds user to the database when the parameters are valid", %{conn: conn} do
      user_count =
        Repo.all(Lodging.Accounts.User)
        |> Enum.count()

      post(conn, Routes.account_path(conn, :create), user: @valid_attrs)

      new_user_count =
        Repo.all(Lodging.Accounts.User)
        |> Enum.count()

      assert user_count == new_user_count - 1
    end

    test "doesnt add users to the database if the parameters are invalid", %{conn: conn} do
      user_count =
        Repo.all(Lodging.Accounts.User)
        |> Enum.count()

      post(conn, Routes.account_path(conn, :create), user: %{@valid_attrs | name: "invalid", username: "inv"})
      post(conn, Routes.account_path(conn, :create), user: %{@valid_attrs | email_address: "invalid"})

      new_user_count =
        Repo.all(Lodging.Accounts.User)
        |> Enum.count()

      assert user_count == new_user_count
    end

    test "redirects to email verification page when a new user is added", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), user: @valid_attrs)

      assert html_response(conn, 302)
      assert redirected_to(conn) == Routes.account_path(conn, :send_email_verification, @user1_id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.account_path(conn, :create),
          user: %{@valid_attrs | username: "inv"}
        )

      assert html_response(conn, 200) =~ "User registration"
    end
  end

  describe "User login - " do
    setup [:user_account]

    test "with valid parameters logs user in", %{conn: conn, user: _user} do
      conn =
        post(conn, Routes.session_path(conn, :create),
          session: %{
            username: @valid_attrs.username,
            password: @valid_attrs.password
          }
        )

      assert Routes.user_path(conn, :home, @user1_id) == redirected_to(conn)
    end

    test "with invalid parameters doesnt log user in", %{conn: conn, user: _user} do
      conn =
        post(conn, Routes.session_path(conn, :create),
          session: %{
            username: @valid_attrs.username,
            password: "invalidPa$$word"
          }
        )

      redirected_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redirected_path)
      assert html_response(conn, 200) =~ "YOUR ONE STOP SERVICES BOOKING PLATFORM"
  end
end

  describe "Account verification - " do
    setup [:unverified_user_account]

    test "Logging in to an unverified user shows a link to verify", %{conn: conn, user: _user} do
      conn =
        post(conn, Routes.session_path(conn, :create),
          session: %{
            username: @unverified_valid_attrs.username,
            password: @unverified_valid_attrs.password
          }
        )

      assert html_response(conn, 200) =~ "YOUR ONE STOP SERVICES BOOKING PLATFORM"
      assert html_response(conn, 200) =~ "You arent verified!"
    end

    test "verifying user works", %{conn: conn, user: user} do
      token = Token.generate_new_account_token(user)

      conn =
        conn
        |> Plug.Test.init_test_session(unverified_user: user.id)
        |> get(Routes.account_path(conn, :verify_email, user.id), token: token)

      redirected_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redirected_path)
      assert html_response(conn, 200) =~ "Your account is now verified!"

      conn =
        post(conn, Routes.session_path(conn, :create),
          session: %{
            username: @unverified_valid_attrs.username,
            password: @unverified_valid_attrs.password
          }
        )

      assert html_response(conn, 302)
    end

    test "using verification url multiple times shows that user is already verified", %{
      conn: conn,
      user: user
    } do
      token = Token.generate_new_account_token(user)

      conn =
        conn
        |> Plug.Test.init_test_session(unverified_user: user.id)
        |> get(Routes.account_path(conn, :verify_email, user.id), token: token)

      redirected_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redirected_path)
      assert html_response(conn, 200) =~ "Your account is now verified!"

      conn =
        conn
        |> get(Routes.account_path(conn, :verify_email, user.id), token: token)

      redirected_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redirected_path)
      assert html_response(conn, 200) =~ "You are already verified"
    end
  end

end
