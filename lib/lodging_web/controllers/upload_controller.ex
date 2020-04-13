defmodule LodgingWeb.UploadController do
  use LodgingWeb, :controller
  @moduledoc """
  Controller for handling actions related to the uploads.
  """

  alias Lodging.Documents
  alias Lodging.Documents.Upload

  def new(conn, %{"business_id" => business_id, "listing_id" => listing_id}) do
    render(conn, "new.html", business_id: business_id, listing_id: listing_id)
  end

  def create(conn, %{"upload" => %Plug.Upload{}=upload, "business_id" => business_id, "listing_id" => listing_id}) do
    case Documents.create_upload_from_plug_upload(upload, listing_id) do
      {:ok, _upload}->
        conn
        |> put_flash(:info, "File uploaded successfully")
        |> redirect(to: Routes.listing_path(LodgingWeb.Endpoint, :view_all_listings, business_id))

      {:error, reason}->
        put_flash(conn, :error, "error upload file: #{inspect(reason)}")
        render(conn, "new.html")
    end
  end

  def index(conn, _params) do
    uploads = Documents.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end

  def show(conn, %{"upload_id" => id}) do
    upload = Documents.get_upload!(id)
    local_path = Upload.local_path(upload.id, upload.filename)
    send_download conn, {:file, local_path}, filename: upload.filename
  end

  def thumbnail(conn, %{"upload_id" => upload_id}) do
    thumb_path = Upload.thumbnail_path(upload_id)

    conn
    |> put_resp_content_type("image/jpeg")
    |> send_file(200, thumb_path)
  end
end
