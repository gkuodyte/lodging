defmodule LodgingWeb.PageController do
  use LodgingWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
