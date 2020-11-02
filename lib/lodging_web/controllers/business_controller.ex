defmodule LodgingWeb.BusinessController do
  @moduledoc """
  Controller for the businessside functionality.
  """

  import Phoenix.HTML.Link
  use LodgingWeb, :controller
  use OK.Pipe
  alias Ecto.Changeset
  alias Lodging.Accounts.Business
  alias Lodging.{Accounts, EmailSender}
  alias LodgingWeb.Endpoint
  alias LodgingWeb.Plugs.PlugHelper

  def new(conn, _params) do
    changeset = Accounts.change_business(%{})
    render(conn, "newbusiness.html", changeset: changeset)
  end

  def create(conn, %{"business" => business_params}) do
    case Accounts.create_business(business_params) do
      {:ok, business} ->
        conn
        |> redirect(to: Routes.business_path(conn, :send_email_verification, business.id))
        |> halt()

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "newbusiness.html", changeset: changeset)
    end
  end

  def send_email_verification(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)

    if business.verified do
      PlugHelper.throw_404(conn)
    else
      EmailSender.send_verification(business)
      render(conn, "email_verification.html")
    end
  end

  def verify_email(conn, %{"token" => token, "business_id" => business_id}) do
    token
    |> Lodging.Token.verify_new_business_token()
    ~>> Lodging.Accounts.get_business()
    |> case do
      {:ok, business} ->
        verified_business_redirect(conn, business)

      {:error, :expired} ->
        conn
        |> put_flash(:error, [
          "Your verification token has expired",
          link("Click here to send a new verification email",
            to: Routes.business_path(Endpoint, :send_email_verification, business_id)
          ),
          "."
        ])
        |> render("new.html")

      {:error, _error} ->
        PlugHelper.throw_404(conn)
    end
  end

  def verify_email(conn, _) do
    PlugHelper.throw_404(conn)
  end

  def verified_business_redirect(conn, business) do
    if business.verified do
      conn
      |> put_flash(:error, "Verification was unsuccessful")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    else
      Lodging.Accounts.validate_business(business)

      conn
      |> put_flash(:info, "Your account is now verified!")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
