defmodule LodgingWeb.UserControllerTest do
  use LodgingWeb.ConnCase

  alias Lodging.{Accounts, Enquiries, Listings}

  @user1_id Ecto.UUID.generate()
  @business1_id Ecto.UUID.generate()
  @listing1_id Ecto.UUID.generate()

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

  @valid_listing_attrs %{
    accommodation: true,
    property_type: "cabins",
    rooms_number: 20,
    rooms_type: "both",
    guests_number: 20,
    country: "uk",
    street_address: "Test Street",
    city: "Test City",
    postcode: "NE4 5TF",
    night_price: 30,
    catering: false,
    events: true,
    events_type: "Testing",
    id: @listing1_id,
    business_id: @user1_id,
    title: "Testing title",
    config: %{}
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

  describe "Create an enquiry -" do
    setup [:user_account, :login_user]

    test "shows the home page", %{conn: conn, user: user} do

      conn =
        conn
        |> get(Routes.listing_path(conn, :home, user.id))

      assert html_response(conn, 200) =~ "No listings available yet!"
    end

    test "reaches the listings filter page", %{conn: conn, user: user} do
      Listings.create_listing(@valid_listing_attrs)
      conn =
        conn
        |> get(Routes.listing_path(conn, :view_listings, user.id))

      assert html_response(conn, 200) =~ "Filters"
    end

    test "reaches the create enquiry page", %{conn: conn, user: user} do
      {:ok, listing} = Listings.create_listing(@valid_listing_attrs)
      conn =
        conn
        |> get(Routes.listing_path(conn, :enquire_listing, user.id, listing.id))

      assert html_response(conn, 200) =~ "Next"
    end
  end

end
