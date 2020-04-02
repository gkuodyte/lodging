defmodule LodgingWeb.ListingController do
  use LodgingWeb, :controller

  import Plug.Conn
  import Phoenix.LiveView.Controller
  alias Lodging.{Accounts, Listings}
  alias LodgingWeb.Endpoint
  alias LodgingWeb.Live.ListingsLive
  use OK.Pipe

  def home(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)
    render(conn, "home.html", business: business)
  end

  def add_new_listing(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)
    session = %{"business" => business}
    live_render(conn, ListingsLive, session: session)
  end

  def view_all_listings(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)
    listings = Map.get(business, :listings)
    render(conn, "all_listings.html", business: business, listings: listings)
  end

  # Add edit listing functionality

  def delete_listing(conn, %{"business_id" => business_id, "listing_id" => listing_id}) do
    Listings.delete_listing(listing_id)
    conn
    |> put_flash(:info, "Successfully deleted listing")
    |> redirect(to: Routes.listing_path(conn, :view_all_listings, business_id))
    |> halt()

  end
end
