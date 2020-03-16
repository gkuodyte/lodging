defmodule LodgingWeb.Plugs.Business do
  @moduledoc """
  Plug that redirects user if they are not business account.
  """

  alias LodgingWeb.Plugs.PlugHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    current_account = PlugHelper.get_current_user(conn)

    if is_business?(current_account) do
      conn
    else
      conn
      |> PlugHelper.redirect()
    end
  end

  defp is_business?(current_account) do
    current_account.account_type == "business"
  end
end
