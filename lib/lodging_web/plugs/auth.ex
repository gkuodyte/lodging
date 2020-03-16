defmodule LodgingWeb.Plugs.Auth do
  @moduledoc """
  Plug to redirect to login page if user is guest (not logged in).
  """

  import Plug.Conn
  alias Lodging.Accounts.Auth
  alias LodgingWeb.Plugs.PlugHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    if Auth.signed_in?(conn) do
      account = PlugHelper.get_current_user(conn)
      assign(conn, :account, account)
    else
      PlugHelper.redirect(conn)
    end
  end
end
