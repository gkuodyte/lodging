defmodule LodgingWeb.Plugs.PlugHelper do
  @moduledoc """
  A set of helper functions for plugs.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias LodgingWeb.Router.Helpers, as: Routes
  alias Lodging.Accounts

  def redirect(conn) do
    conn
    |> get_session(:current_account_id)
    |> OK.required()
    |> case do
      {:ok, _user_id} ->
        conn
        |> get_session(:account_type)
        |> redir(conn)
        |> halt()

      {:error, _} ->
        redirect_guest(conn)
    end
  end

  defp redirect_guest(conn) do
    conn
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp redir("user", conn) do
    user_id = get_session(conn, :current_account_id)

    conn
    |> redirect(to: Routes.user_path(conn, :home, user_id))
    |> halt()
  end

  defp redir("business", conn) do
    business_id = get_session(conn, :current_account_id)

    conn
    |> redirect(to: Routes.listing_path(conn, :home, business_id))
    |> halt()
  end

  def get_current_user(conn) do
    account_id = Plug.Conn.get_session(conn, :current_account_id)
    account_type = Plug.Conn.get_session(conn, :account_type)

    if account_type == "user" do
      Accounts.get_user!(account_id)
    else
      Accounts.get_business!(account_id)
    end
  end

  defp redir(_, conn) do
    conn
    |> throw_404()
  end

  def throw_404(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(LodgingWeb.ErrorView)
    |> render("404.html")
    |> halt()
  end
end
