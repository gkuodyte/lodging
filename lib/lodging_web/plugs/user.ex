defmodule LodgingWeb.Plugs.User do
  @moduledoc """
  Plug that halts non-user accounts.
  """

  alias LodgingWeb.Plugs.PlugHelper

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = PlugHelper.get_current_user(conn)

    if is_a_user?(current_user) do
      conn
    else
      conn
      |> PlugHelper.redirect()
    end
  end

  defp is_a_user?(%{account_type: account_type}), do: account_type == "user"
end
