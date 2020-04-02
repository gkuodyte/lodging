defmodule Lodging.Accounts.Listing do
  @moduledoc """
  Defines the schema for a listing.
  """

  use Ecto.Schema

  import Ecto.Changeset
  alias Lodging.Accounts.Business

  @primary_key {:id, :binary_id, auto_generate: false}
  schema "listings" do
    field :title, :string
    field :accommodation, :boolean
    field :property_type, :string
    field :rooms_number, :integer
    field :rooms_type, :string
    field :guests_number, :integer
    field :country, :string
    field :street_address, :string
    field :street_address2, :string
    field :city, :string
    field :postcode, :string
    field :night_price, :integer
    field :catering, :boolean
    field :tailorable_menu, :boolean
    field :meals_number, :integer
    field :meals_price_range, :integer
    field :events, :boolean
    field :events_type, :string
    field :contact_number, :string
    field :config, :map
    belongs_to :business, Business, type: :binary_id

    timestamps()
  end

  def changeset(%__MODULE__{} = listing, changes \\ %{}) do
    listing
    |> cast(changes, [
      :title,
      :accommodation,
      :property_type,
      :rooms_number,
      :rooms_type,
      :guests_number,
      :country,
      :street_address,
      :city,
      :catering,
      :postcode,
      :night_price,
      :catering,
      :tailorable_menu,
      :meals_number,
      :events,
      :events_type,
      :contact_number,
      :config,
      :business_id
    ])
    |> validate_postcode()
    |> validate_contact_number()
  end

  defp validate_postcode(%{changes: %{postcode: _}} = changeset) do
    changeset
    |> validate_format(
      :postcode,
      ~r/([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\s?[0-9][A-Za-z]{2})/,
      message: "Please enter a valid UK postcode."
    )
  end

  defp validate_postcode(changeset), do: changeset

  defp validate_contact_number(%{changes: %{contact_number: _}} = changeset) do
    changeset
    |> validate_format(
      :contact_number,
      ~r/^(?:0|\+?44)(?:\d\s?){9,10}$/
    )
  end

  defp validate_contact_number(changeset), do: changeset
end
