defmodule Lodging.Enquiries do
  @moduledoc """
  The Enquiries context. Functions for reading and writing to the database.
  """

  import Ecto.Query, warn: false
  alias Lodging.Repo
  alias Lodging.Accounts.Enquiry

  def change_enquiry(%Enquiry{} = enquiry \\ %Enquiry{}, %{} = changes) do
    enquiry
    |> Enquiry.changeset(changes)
  end

  def create_enquiry(%{} = data) do
    %Enquiry{id: Ecto.UUID.generate()}
    |> change_enquiry(data)
    |> Repo.insert()
  end

  def all_enquiries do
    Repo.all(Enquiry)
  end

  def get_enquiry!(id) do
    Repo.get!(Enquiry, id)
  end

  def update_enquiry_info(%Enquiry{} = enquiry, attrs) do
    enquiry
    |> Enquiry.changeset(attrs)
    |> Repo.update()
  end
end
