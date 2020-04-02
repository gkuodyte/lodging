defmodule Lodging.Listings do
  @moduledoc """
  The Listings context.
  """

  import Ecto.Query, warn: false
  use OK.Pipe
  alias Lodging.Repo
  alias Lodging.Accounts.Listing

  def change_listing(%Listing{} = listing \\ %Listing{}, %{} = changes) do
    listing
    |> Listing.changeset(changes)
  end

  def create_listing(%{} = data) do
    %Listing{id: Ecto.UUID.generate()}
    |> change_listing(data)
    |> Repo.insert()
  end

  def all_listings do
    Repo.all(Listing)
  end

  def get_listing!(id) do
    Repo.get!(Listing, id)
  end

  def get_listing(id) do
    Repo.get(Listing, id)
    |> case do
      nil -> {:error, id}
      listing -> {:ok, listing}
    end
  end

  def delete_listing(id) do
    listing = Repo.get!(Listing, id)
    Repo.delete(listing)
  end

  def listings_cities do
    Repo.all(Listing)
    Ecto.Adapters.SQL.query!(Lodging.Repo, "SELECT city FROM listings ORDER BY city ASC")
  end
end
