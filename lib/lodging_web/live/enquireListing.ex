defmodule LodgingWeb.Live.EnquireListing do
  use Phoenix.LiveView

  alias LodgingWeb.Router.Helpers, as: Routes
  alias Lodging.Enquiries
  alias Lodging.Accounts.Enquiry
  alias Lodging.EmailSender

  @pages [
    "listing_info.html",
    "listing_accommodation.html",
    "listing_catering_events.html",
    "listing_extra_info.html"
  ]

  def mount(_params, %{"user" => user, "listing" => listing, "business" => business}, socket) do
    inputs = %{"listing_id" => listing.id, "user_id" => user.id, "business_id" => business.id}
    socket =
      socket
      |> assign(:inputs, inputs)
      |> assign(:changeset, Enquiries.change_enquiry(%Enquiry{}, inputs))
      |> assign(:user, user)
      |> assign(:listing, listing)
      |> assign(:business, business)
      |> assign(:current_index, 0)

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(LodgingWeb.UserView, Enum.at(@pages, assigns.current_index), assigns)
  end

  def handle_event("add_input", %{"enquiry" => new_inputs}, %{assigns: %{inputs: inputs}} = socket) do

    inputs = Map.merge(inputs, new_inputs)
    new_changeset = Lodging.Enquiries.change_enquiry(inputs)

    socket
    |> assign(changeset: new_changeset, inputs: inputs)
    |> noreply()
  end

  def handle_event("next", _values, %{assigns: %{current_index: current_index, listing: listing}} = socket) do
    next_index =
      if listing.accommodation do
        current_index + 1
      else
        current_index + 3
      end

    socket
    |> assign(:current_index, next_index)
    |> noreply()
  end

  def handle_event("previous", _values, %{assigns: %{current_index: current_index, listing: listing}} = socket) do
    previous_index =
      if listing.accommodation == false do
        current_index - 3
      else
        current_index - 1
      end

      socket
      |> assign(:current_index, previous_index)
      |> noreply()

  end

  def handle_event("submit", _values, %{assigns: %{inputs: inputs, listing: listing, user: user, business: business}} = socket) do
    Enquiries.create_enquiry(inputs)
    |> case do
      {:ok, _} ->
        EmailSender.send_enquiry_user(user, business)
        EmailSender.send_enquiry_business(business, user)
        {:noreply,
        socket
        |> put_flash(:info, "Enquiry has been submitted successfully")
        |> redirect(to: Routes.user_path(LodgingWeb.Endpoint, :open_listing, user.id, listing.id))
      }

      {:error, _} ->
        {:noreply,
        socket
        |> put_flash(:error, "An issue occured trying to submit your enquiry. Please try again later")
      }
    end
  end

  def noreply(socket), do: {:noreply, socket}
end
