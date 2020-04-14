defmodule LodgingWeb.ListingController do
  use LodgingWeb, :controller

  import Plug.Conn
  import Phoenix.LiveView.Controller
  import Ecto.Query, warn: false
  alias Lodging.{Accounts, Listings, Documents, Enquiries}
  alias Lodging.Image
  alias LodgingWeb.Endpoint
  alias LodgingWeb.Live.ListingsLive
  alias Lodging.Repo
  alias Lodging.Images
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
    images = Repo.all(Image)
    render(conn, "all_listings.html", business: business, listings: listings, images: images)
  end

  def edit_listing(conn, %{"business_id" => business_id, "listing_id" => listing_id}) do
    business = Accounts.get_business!(business_id)
    listing = Listings.get_listing!(listing_id)
    changeset = Listings.change_listing(listing, %{})
    render(conn, "edit_listing.html", business: business, listing: listing, changeset: changeset)
  end

  def update_listing(conn, %{"business_id" => business_id, "listing_id" => listing_id, "listing" => new_params}) do
    listing = Listings.get_listing!(listing_id)

    if Map.get(new_params, "image") != nil do
      image = Map.get(new_params, "image")
        %{}
        |> Map.put("image", image)
        |> Map.put("listing_id", listing_id)
        |> Images.create_image()
        |> case do
          {:ok, _upload}->
            put_flash(conn, :info, "File uploaded successfully")

          {:error, reason}->
            put_flash(conn, :error, "Error uploading file: #{inspect(reason)}")
        end
    end

    config =
    if Map.get(new_params, "description") != "" do
      {desc, params} = Map.pop(new_params, "description")
      config =
        %{}
        |> Map.put("description", desc)

        Map.put(params, "config", config)
    else
      new_params
    end

    params = Map.merge(new_params, config)
    case Listings.update_listing_info(listing, params) do
      {:ok, _new_listing} ->
        conn
        |> put_flash(:info, "Listing has been updated successfully")
        |> redirect(to: Routes.listing_path(LodgingWeb.Endpoint, :view_all_listings, business_id))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Listing couldn't be updated at this time. Try again later")
        |> redirect(to: Routes.listing_path(LodgingWeb.Endpoint, :view_all_listings, business_id))
    end
  end

  def delete_listing(conn, %{"business_id" => business_id, "listing_id" => listing_id}) do
    Listings.delete_listing(listing_id)
    conn
    |> put_flash(:info, "Successfully deleted listing")
    |> redirect(to: Routes.listing_path(conn, :view_all_listings, business_id))
    |> halt()
  end

  def view_enquiries(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)
    all_enquiries = Enquiries.all_enquiries()
    enquiries =
      Enum.filter(all_enquiries, fn enquiry -> enquiry.business_id == business_id end)
    listings = Listings.all_listings()
    render(conn, "all_enquiries.html", business: business, enquiries: enquiries, listings: listings)
  end

  def view_enquiry(conn, %{"business_id" => business_id, "enquiry_id" => enquiry_id}) do
    business = Accounts.get_business!(business_id)
    enquiry = Enquiries.get_enquiry!(enquiry_id)
    listings = listings = Listings.all_listings()
    [listing] = Enum.filter(listings, fn listing -> listing.id == enquiry.listing_id end)
    render(conn, "view_enquiry.html", business: business, enquiry: enquiry, listing: listing)
  end
end
