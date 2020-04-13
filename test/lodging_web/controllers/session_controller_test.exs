defmodule LodgingWeb.SessionControllerTest do
  use LodgingWeb.ConnCase

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

  def user_account(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_user()

    {:ok, user: user}
  end

  def login_user(%{conn: conn, user: user}) do
    conn =
      conn
      |> Plug.Test.init_test_session(%{
        current_account_id: user.id,
        account_type: user.account_type
      })

    {:ok, conn: conn}
  end

  describe "delete route" do
    setup [:user_account, :login_user]

    test "logs user out as expected", %{conn: conn} do
      conn =
        conn
        |> get(Routes.session_path(conn, :delete))

      redirected_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redirected_path)

      assert Routes.session_path(conn, :new) == conn.request_path
      assert :current_user not in conn.private.plug_session
    end
  end

end
