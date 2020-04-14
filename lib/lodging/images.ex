defmodule Lodging.Images do

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Lodging.Repo
  alias Lodging.Image

  def change_image(%Image{} = image \\ %Image{}, changes) do
    image
    |> Image.changeset(changes)
  end

  def create_image(data) do
    %Image{}
    |> change_image(data)
    |> Repo.insert()
  end
end
