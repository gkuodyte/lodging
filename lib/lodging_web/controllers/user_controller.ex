defmodule LodgingWeb.UserController do
  use LodgingWeb, :controller
  import Phoenix.LiveView.Controller
  alias Lodging.{Listings, Accounts, Enquiries, EmailSender}
  alias LodgingWeb.Endpoint
  alias LodgingWeb.Live.UserListings
  alias LodgingWeb.Live.EnquireListing

  def home(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    listings = Listings.all_listings()
    render(conn, "home.html", user: user, listings: listings)
  end

  def view_listings(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    listings = Listings.all_listings()
    session = %{"user" => user, "listings" => listings}
    live_render(conn, UserListings, session: session)
  end

  def open_listing(conn, %{"user_id" => user_id, "listing_id" => listing_id}) do
    listing = Listings.get_listing!(listing_id)
    business_id = Map.get(listing, :business_id)
    business = Accounts.get_business!(business_id)
    user = Accounts.get_user!(user_id)
    render(conn, "listing.html", listing: listing, business: business, user: user)
  end

  def enquire_listing(conn, %{"user_id" => user_id, "listing_id" => listing_id}) do
    user = Accounts.get_user!(user_id)
    listing = Listings.get_listing!(listing_id)
    business_id = Map.get(listing, :business_id)
    business = Accounts.get_business!(business_id)
    session = %{"user" => user, "listing" => listing, "business" => business}
    live_render(conn, EnquireListing, session: session)
  end

  def view_enquiries(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)
    enquiries = Enquiries.all_enquiries()
    user_enquiries =
      enquiries
      |> Enum.filter(fn listing -> Map.get(listing, :user_id) == user_id
      end)

      render(conn, "enquiries.html", user: user, user_enquiries: user_enquiries)
  end

  def open_enquiry(conn, %{"user_id" => user_id, "enquiry_id" => enquiry_id}) do
    user = Accounts.get_user!(user_id)
    enquiry = Enquiries.get_enquiry!(enquiry_id)
    render(conn, "enquiry.html", enquiry: enquiry, user: user)
  end

  def edit_enquiry(conn, %{"user_id" => user_id, "enquiry_id" => enquiry_id}) do
    user = Accounts.get_user!(user_id)
    enquiry = Enquiries.get_enquiry!(enquiry_id) |> IO.inspect(label: "enquiry")
    listing = Listings.get_listing!(enquiry.listing_id)
    changeset = Enquiries.change_enquiry(enquiry, %{})

    render(conn, "enquiry_edit.html", enquiry: enquiry, user: user, changeset: changeset, listing: listing)
  end

  def update_enquiry(conn, %{"user_id" => user_id, "enquiry_id" => enquiry_id, "enquiry" => enquiry_params}) do
    enquiry = Enquiries.get_enquiry!(enquiry_id)
    business = Accounts.get_business!(enquiry.business_id)
    user = Accounts.get_user!(user_id)
    case Enquiries.update_enquiry_info(enquiry, enquiry_params) do
      {:ok, _} ->
        EmailSender.send_update_enquiry_user(user, business)
        EmailSender.send_update_enquiry_business(business, user)

        conn
        |> put_flash(:info, "Enquiry has been updated successfully")
        |> redirect(to: Routes.user_path(LodgingWeb.Endpoint, :open_enquiry, user_id, enquiry_id))

        {:error, _message} ->
          conn
          |> put_flash(:error, "Couldnt updaet the enquiry")
          |> redirect(to: Routes.user_path(LodgingWeb.Endpoint, :edit_enquiry, user_id, enquiry_id))

    end
  end
end
