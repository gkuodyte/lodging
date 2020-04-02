defmodule LodgingWeb.Live.ListingsLive do
  use Phoenix.LiveView
  alias LodgingWeb.Router.Helpers, as: Routes
  alias Lodging.Accounts.Listing
  alias Lodging.Listings

  @pages [
    "company_form_new.html",
    "company_form.html",
    "company_form_address.html",
    "company_form_extra.html"
  ]

  def mount(_params, %{"business" => business}, socket) do
    inputs = %{"business_id" => business.id}
    socket =
      socket
      |> assign(:inputs, inputs)
      |> assign(:changeset, Listings.change_listing(%Listing{}, inputs))
      |> assign(:business, business)
      |> assign(:current_index, 0)

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(LodgingWeb.ListingView, Enum.at(@pages, assigns.current_index), assigns)
  end

  def handle_event(
        "add_input",
        %{"listing" => new_inputs},
        %{
          assigns: %{
            inputs: inputs
          }
        } = socket
      ) do

        added_inputs =
        if Map.get(new_inputs, "description") != "" do
          {desc, updated_inputs} = Map.pop(new_inputs, "description")

          config =
            %{}
            |> Map.put("description", desc)

            Map.put(updated_inputs, "config", config)
        else
          new_inputs
        end

    inputs = Map.merge(inputs, added_inputs)
    new_changeset = Lodging.Listings.change_listing(inputs)

    socket
    |> assign(changeset: new_changeset, inputs: inputs)
    |> noreply()
  end

  def handle_event("next", _values, %{assigns: %{current_index: current_index, inputs: inputs}} = socket) do
    next_index =
      if Map.get(inputs, "accommodation") != "false" do
        current_index + 1
      else
        current_index + 3
      end

    socket
    |> assign(:current_index, next_index)
    |> noreply()
  end

  def handle_event("previous", _values, %{assigns: %{current_index: current_index, inputs: inputs}} = socket) do
    previous_index =
      if Map.get(inputs, "accommodation") == "false" do
        current_index - 3
      else
        current_index - 1
      end

      socket
      |> assign(:current_index, previous_index)
      |> noreply()

  end

  def handle_event("submit", _values, %{assigns: %{inputs: inputs, business: business}} = socket) do
    Listings.create_listing(inputs)
    |> case do
      {:ok, _} ->
        {:noreply,
        socket
        |> put_flash(:info, "Listing has been created successfully")
        |> redirect(to: Routes.listing_path(LodgingWeb.Endpoint, :view_all_listings, business.id))
      }

      {:error, _} ->
        {:noreply,
        socket
        |> put_flash(:error, "An issue has occured. Please retry later.")}
    end
  end

  def noreply(socket), do: {:noreply, socket}
end
