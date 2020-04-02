defmodule Lodging.Accounts.Enquiry do
  @moduledoc """
  Defines the schema for an enquiry.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Lodging.Accounts.Listing

  @primary_key {:id, :binary_id, auto_generate: false}
  schema "enquiries" do
    field :user_id, :binary_id
    field :business_id, :binary_id
    field :accommodation, :boolean
    field :guests_number, :integer
    field :catering, :boolean
    field :tailorable_menu, :boolean
    field :meals_number, :integer
    field :events, :boolean
    field :comment, :string
    field :day, :string, virtual: true
    field :month, :string, virtual: true
    field :year, :string, virtual: true
    field :day_to, :string, virtual: true
    field :month_to, :string, virtual: true
    field :year_to, :string, virtual: true
    field :date_from, :date
    field :date_to, :date
    field :contact_number, :string
    belongs_to :listing, Listing, type: :binary_id

    timestamps()
  end

  def changeset(%__MODULE__{} = enquiry, changes \\ %{}) do
    enquiry
    |> cast(changes, [
      :user_id,
      :business_id,
      :accommodation,
      :guests_number,
      :catering,
      :tailorable_menu,
      :meals_number,
      :events,
      :comment,
      :day,
      :month,
      :year,
      :day_to,
      :month_to,
      :year_to,
      :listing_id,
      :contact_number
    ])
    |> set_date_from()
    |> set_date_to()
  end

  def set_date_from(%{changes: %{day: day, month: month, year: year}} = changeset) do
    date =
      [year, month, day]
      |> convert_to_two_digits()
      |> Enum.join("-")

    case Timex.parse(date, "%Y-%m-%d", :strftime) do
      {:ok, newDate} ->
        if valid_from_date?(newDate) == true do
          put_change(changeset, :date_from, Timex.to_date(newDate))
        else
          add_error(changeset, :date_from, "Date is invalid.")
        end

      {:error, _message} ->
        add_error(changeset, :date_from, "The date is incorrect.")
    end
  end

  def set_date_from(changeset), do: changeset

  def set_date_to(%{changes: %{day_to: day_to, month_to: month_to, year_to: year_to, date_from: date_from}} = changeset) do
    date =
    [year_to, month_to, day_to]
    |> convert_to_two_digits()
    |> Enum.join("-")

    case Timex.parse(date, "%Y-%m-%d", :strftime) do
      {:ok, newDate} ->
        if valid_to_date?(date_from, newDate) == true do
          put_change(changeset, :date_to, Timex.to_date(newDate))
        else
          add_error(changeset, :date_to, "Date is invalid.")
        end

      {:error, _message} ->
        add_error(changeset, :date_to, "The date is incorrect.")
    end
  end

  def set_date_to(changeset), do: changeset

  def set_date_for_enquiry(changeset), do: changeset

  def valid_from_date?(date) do
    Timex.before?(Timex.today, date)
  end

  def valid_to_date?(from, date) do
    Timex.before?(from, date)
  end

  def convert_to_two_digits(date_list) do
    Enum.map(date_list, &force_two_digits/1)
  end

  def force_two_digits(number) when is_binary(number) do
    if String.length(number) > 1 do
      number
    else
      "0" <> number
    end
  end
end
