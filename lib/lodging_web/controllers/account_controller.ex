defmodule LodgingWeb.AccountController do
  @moduledoc """
  Controller for handling actions related to a unique user.
  """

  import Phoenix.HTML.Link
  use LodgingWeb, :controller
  use OK.Pipe
  alias Ecto.Changeset
  alias Lodging.Accounts.User
  alias Lodging.{Accounts, EmailSender}
  alias LodgingWeb.Endpoint
  alias LodgingWeb.Plugs.PlugHelper

  @doc """
  Path to display form for creating a new user.
  """

  def new(conn, _params) do
    changeset = Accounts.change_user(%{})
    render(conn, "registration.html", changeset: changeset)
  end

  @doc """
  Path to verify the inputs and create a new user.
  """
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> redirect(to: Routes.account_path(conn, :send_email_verification, user.id))
        |> halt()

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "registration.html", changeset: changeset)
    end
  end

  @doc """
  Upon registration completion, send a verification email to verify their email address.
  """
  def send_email_verification(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id)

    if user.verified do
      PlugHelper.throw_404(conn)
    else
      EmailSender.send_verification(user)
      render(conn, "email_verification.html")
    end
  end

  @doc """
  Path to verify user when a token is passed in
  """
  def verify_email(conn, %{"token" => token, "user_id" => user_id}) do
    token
    |> Lodging.Token.verify_new_account_token()
    ~>> Lodging.Accounts.get_user()
    |> case do
      {:ok, user} ->
        verified_user_redirect(conn, user)

      {:error, :expired} ->
        conn
        |> put_flash(:error, [
          "Your verification token has expired",
          link("Click here to send a new verification email",
            to: Routes.account_path(Endpoint, :send_email_verification, user_id)
          ),
          "."
        ])
        |> render("new.html")

      {:error, _error} ->
        PlugHelper.throw_404(conn)
    end
  end

  def verified_user_redirect(conn, user) do
    if user.verified do
      conn
      |> put_flash(:error, "You are already verified")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    else
      Lodging.Accounts.validate_user(user)

      conn
      |> put_flash(:info, "Your account is now verified!")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  @doc """
  Path to verify user when there is no token passed in
  """
  def verify_email(conn, _) do
    PlugHelper.throw_404(conn)
  end
end
