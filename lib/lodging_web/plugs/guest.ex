defmodule LodgingWeb.Plugs.Guest do
  @moduledoc """
  Plug to redirect the user to an authenticated page if they are logged in (not guest).
  """

  alias LodgingWeb.Plugs.PlugHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    if Plug.Conn.get_session(conn, :current_account_id) do
      PlugHelper.redirect(conn)
    else
      conn
    end
  end
end
