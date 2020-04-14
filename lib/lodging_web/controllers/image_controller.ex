defmodule LodgingWeb.ImageController do

  use LodgingWeb, :controller
  import Ecto.Query, warn: false
  alias Lodging.Image
  alias Lodging.Repo
  alias Lodging.Images

  def new(conn, %{"business_id" => business_id, "listing_id" => listing_id}) do
    changeset = Image.changeset(%Image{}, %{})
    render(conn, "new.html", business_id: business_id, listing_id: listing_id, changeset: changeset)
  end

  def create(conn, %{"image" => image_params, "business_id" => business_id, "listing_id" => listing_id}) do
    new_image_params =
      image_params
      |> Map.put("listing_id", listing_id)

    case Images.create_image(new_image_params) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, "Image saved successfully.")
        |> redirect(to: Routes.listing_path(LodgingWeb.Endpoint, :view_all_listings, business_id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Couldnt save image")
        |> render("new.html", changeset: changeset)
    end
  end

    def index(conn, %{"id" => id}) do
      image = Repo.get(Image, id)
      conn
      |> encode_image(image)
  end

  defp encode_image(conn, image) do
      conn
      |> put_layout(:none)
      |> put_resp_content_type(image.image_type)
      |> resp(200, :base64.decode(image.image_data))
      |> send_resp()
      |> halt()
  end
end
