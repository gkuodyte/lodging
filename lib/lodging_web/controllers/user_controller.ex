defmodule LodgingWeb.UserController do
  use LodgingWeb, :controller

  def home(conn, _params) do
    # get all businesses
    # show all available filters for existing businesses

    render(conn, "home.html")
  end
end
