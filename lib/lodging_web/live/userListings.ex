defmodule LodgingWeb.Live.UserListings do
  use Phoenix.LiveView

  use OK.Pipe
  require Logger
  alias LodgingWeb.Router.Helpers, as: Routes
  alias Lodging.Accounts.Listing
  alias Lodging.Listings

  @default_filter %{
    accommodation: nil,
    guests_number: nil,
    catering: nil,
    events: nil,
    city: nil
  }
  def mount(_params, %{"user" => user, "listings" => listings}, socket) do
    filter = @default_filter

    cities =
      listings
      |> Enum.map(fn listing -> listing.city end)
      |> Enum.uniq()

    socket
    |> assign(:filter, filter)
    |> assign(:listings, listings)
    |> assign(:shown_listings, listings)
    |> assign(:cities, cities)
    |> assign(:user, user)
    |> OK.wrap()
  end

  def render(assigns) do
    Phoenix.View.render(LodgingWeb.UserView, "listings.html", assigns)
  end

  def handle_event("update_filter", %{"filter" => filter}, %{assigns: %{listings: listings}} = socket) do
    filter = transform_filter(filter)

    socket
    |> assign(filter: filter)
    |> assign(shown_listings: filter_listings(listings, filter))
    |> noreply()
  end

  defp transform_filter(filter) do
    city = if filter["city"] == "", do: nil, else: filter["city"]
    guests_number = if filter["guests_number"] in ["", nil], do: nil, else: String.to_integer(filter["guests_number"])
    %{
      accommodation: get_value_or_nil(filter["accommodation"]),
      catering: get_value_or_nil(filter["catering"]),
      events: get_value_or_nil(filter["events"]),
      guests_number: guests_number,
      city: city
    }
  end

  defp get_value_or_nil(nil), do: nil
  defp get_value_or_nil(value), do: !!value

  defp filter_listings(listings, %{
    accommodation: accommodation,
    guests_number: guests_number,
    catering: catering,
    events: events,
    city: city
  })  do
    listings
    |> Enum.filter(fn listing ->
      listing
      |> Map.from_struct()
      |> check_filter(:accommodation, accommodation)
      ~>> check_filter(:catering, catering)
      ~>> check_filter(:events, events)
      ~>> check_filter(:city, city)
      ~>> correct_guests_number(guests_number)
      |> OK.success?()
    end)
  end

  defp check_filter(listing, _key, nil), do: {:ok, listing}
  defp check_filter(listing, key, filter) do
    if listing[key] == filter do
      {:ok, listing}
    else
      Logger.warn("#{listing[key]} is not equal to #{filter} on key #{key}")
      {:error, listing}
    end
  end

  defp correct_guests_number(listing, nil), do: {:ok, listing}
  defp correct_guests_number(listing, filter) do
    if filter <= listing.guests_number do
      {:ok, listing}
    else
      {:error, listing}
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
