defmodule Lodging.Image do

  use Ecto.Schema
  import Ecto.Changeset
  alias Lodging.Accounts.Listing

  schema "images" do
    field :image, :any, virtual: true
    field :image_data, :binary
    field :image_name, :string
    field :image_type, :string
    belongs_to :listing, Listing, type: :binary_id

    timestamps()
end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:image, :listing_id])
    |> store_image
  end

  defp store_image(changeset) do
    case changeset do
        %Ecto.Changeset{valid?: true, changes: %{image: image, listing_id: listing_id}} ->
            changeset
            |> put_change(:image_type, image.content_type)
            |> put_change(:image_name, image.filename)
            |> put_change(:image_data, :base64.encode(File.read!(image.path)))
            |> put_change(:listing_id, listing_id)
        _ -> changeset
    end
end
end
