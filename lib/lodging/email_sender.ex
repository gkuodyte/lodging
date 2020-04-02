defmodule Lodging.EmailSender do
  @moduledoc """
  Handles outgoing verification emails.
  """

  alias Lodging.Accounts.{User, Business}
  alias Lodging.{Email, Mailer, Token}
  alias LodgingWeb.{Endpoint, Router.Helpers}

  @doc """
  Sends out an email containing a url for verifying an account.
  """

  def send_verification(%User{} = user) do
    token = Token.generate_new_account_token(user)

    verification_url = Helpers.account_url(Endpoint, :verify_email, user.id, token: token)

    Email.verification_email(user.name, user.email_address, verification_url)
    |> Mailer.deliver_now()
  end

  def send_verification(%Business{} = business) do
    token = Token.generate_new_business_token(business)
    verification_url = Helpers.business_url(Endpoint, :verify_email, business.id, token: token)

    Email.verification_email(business.name, business.email_address, verification_url)
    |> Mailer.deliver_now()
  end

   @doc """
  Sends out an email letting know about new enquiries.
  """

  def send_enquiry_user(%User{} = user, business) do
    Email.enquiry_email_user(business.name, user.email_address)
    |> Mailer.deliver_now()
  end

  def send_enquiry_business(%Business{} = business, user) do
    Email.enquiry_email_business(user.name, business.email_address)
    |> Mailer.deliver_now()
  end

  def send_update_enquiry_user(%User{} = user, business) do
    Email.enquiry_update_email_user(business.name, user.email_address)
    |> Mailer.deliver_now()
  end

  def send_update_enquiry_business(%Business{} = business, user) do
    Email.enquiry_update_email_business(user.name, business.email_address)
    |> Mailer.deliver_now()
  end
end
