defmodule LodgingWeb.ListingControllerTest do
  use LodgingWeb.ConnCase

  alias Lodging.{Listings, Accounts}

  @business1_id Ecto.UUID.generate()
  @listing1_id Ecto.UUID.generate()

  @valid_attrs %{
    id: @business1_id,
    username: "TestUser",
    name: "Test Name",
    lastname: "Surname",
    email_address: "test_email@test.com",
    password: "TestingPass123",
    password_confirmation: "TestingPass123",
    account_type: "business",
    terms_and_conditions: true,
    verified: true,
    business_name: "TestBusiness",
    business_address: "Test Address",
    business_number: "07765131716",
    accommodation: true,
    catering: true,
    events: true
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

  def business_account(attrs \\ %{}) do
    {:ok, business} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_business()

    {:ok, business: business}
  end

  def login_business(%{conn: conn, business: business}) do
    conn =
      conn
      |> Plug.Test.init_test_session(%{
        current_account_id: business.id,
        account_type: business.account_type
      })

    {:ok, conn: conn}
  end

  describe "Create a new listing -" do
    setup [:business_account, :login_business]

    test "shows the home page", %{conn: conn, business: business} do
      conn =
        conn
        |> get(Routes.listing_path(conn, :home, business.id))

      assert html_response(conn, 200) =~ "Create your first listing"
    end

    test "reaches the listing creation template", %{conn: conn, business: business} do
      conn =
        conn
        |> get(Routes.listing_path(conn, :add_new_listing, business.id))

      assert html_response(conn, 200) =~ "Please complete your listing"
    end

    test "adds it to the database if parameters are valid", %{conn: conn, business: business} do
      listings_count =
        Listings.all_listings()
        |> Enum.count()

      Listings.create_listing(@valid_listing_attrs)

      new_listings_count =
        Listings.all_listings()
        |> Enum.count()

      assert listings_count == new_listings_count - 1
    end

    test "doesnt add to the database with invalid parameters", %{conn: conn, business: business} do
      listings_count =
        Listings.all_listings()
        |> Enum.count()

        Listings.create_listing(%{@valid_listing_attrs | title: nil})

      new_listings_count =
        Listings.all_listings()
        |> Enum.count()

      assert listings_count == new_listings_count
    end
  end

  describe "Existing listings - " do
    setup [:business_account, :login_business]

    test "home page allows to view", %{conn: conn, business: business} do
      Listings.create_listing(@valid_listing_attrs)
      conn =
        conn
        |> get(Routes.listing_path(conn, :home, business.id))

      assert html_response(conn, 200) =~ "View your existing listings"
    end

    test "in listings page, loads all listings and is a create button", %{conn: conn, business: business} do
      Listings.create_listing(@valid_listing_attrs)
      conn =
        conn
        |> get(Routes.listing_path(conn, :view_all_listings, business.id))

      assert html_response(conn, 200) =~ "View your listings here"
      assert html_response(conn, 200) =~ "Create a new listing"
    end

    test "render edit page for existing listing", %{conn: conn, business: business} do
      {:ok, listing} = Listings.create_listing(@valid_listing_attrs)
      conn =
        conn
        |> get(Routes.listing_path(conn, :edit_listing, business.id, listing.id))

      assert html_response(conn, 200) =~ "Please edit your listing here"
    end

    test "update existing listing", %{conn: conn, business: business} do
      {:ok, listing} = Listings.create_listing(@valid_listing_attrs)
      conn =
        conn
        |> post(Routes.listing_path(conn, :update_listing, business.id, listing.id))

      assert html_response(conn, 302)
      assert Routes.listing_path(conn, :view_all_listings, business.id) == conn.request_path
    end
  end
end
