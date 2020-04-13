defmodule LodgingWeb.SessionController do
  @moduledoc """
  Controller for handling actions related to the login session.
  """

  use LodgingWeb, :controller

  import Phoenix.HTML.Link
  alias Lodging.Accounts.Auth
  alias LodgingWeb.Endpoint

  @doc """
  Route to display login page
  """
  def new(conn, _params) do
    render(conn, "new.html")
  end

  @doc """
  Route to generate a new login session.
  """
  def create(conn, %{"session" => auth_params}) do
    case get_account(auth_params) do
      {:ok, :user, account} ->
        verified_account_redirect(
          conn,
          account,
          Routes.user_path(Endpoint, :home, account.id),
          Routes.account_path(Endpoint, :send_email_verification, account.id)
        )

      {:ok, :business, account} ->
        verified_account_redirect(
          conn,
          account,
          Routes.listing_path(Endpoint, :home, account.id),
          Routes.business_path(Endpoint, :send_email_verification, account.id)
        )

      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was a problem with your username / password")
        |> redirect(to: Routes.session_path(Endpoint, :new))
        |> halt()
    end
  end

  defp get_account(auth_params) do
    user_result = Auth.login_user(auth_params)
    business_result = Auth.login_business(auth_params)

    cond do
      OK.success? user_result -> {:ok, :user, elem(user_result, 1)}
      OK.success? business_result -> {:ok, :business, elem(business_result, 1)}
      true -> {:error, :account_does_not_exist}
    end
  end

  defp verified_account_redirect(conn, account, new_account_path, _new_redirect_path) do
    # if account.verified do
      conn
      |> put_session(:current_account_id, account.id)
      |> put_session(:account_type, account.account_type)
      |> configure_session(renew: true)
      |> redirect(to: new_account_path)
      |> halt()
    # else
    #   conn
    #   |> put_flash(:error, [
    #     "You arent verified!",
    #     link("Click here to send a new email",
    #       to: new_redirect_path
    #     ),
    #     "."
    #   ])
    #   |> render("new.html")
    # end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end
