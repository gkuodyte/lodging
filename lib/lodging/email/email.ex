defmodule Lodging.Email do
  @moduledoc """
  Email templates for sending email.
  """

  import Bamboo.Email
  @from {"Lodging platform", "noreply@gabijakuodyte.com"}

  def verification_email(name, email, verification_url) do
    new_email(
      to: email,
      from: @from,
      subject: "User verification",
      html_body: "<strong> Thank you for registering at Lodging, #{name}.</strong>",
      html_body: "Follow this link to verify your account: #{verification_url}"
    )
  end

  def enquiry_email_user(business_name, email) do
    new_email(
      to: email,
      from: @from,
      subject: "New enquiry sent",
      html_body: "<strong> Thank you for sending your enquiry to #{business_name}. </strong>",
      html_body: "You can view your completed enquiries in your enquiries folder."
    )
  end

  def enquiry_email_business(user_name, email) do
    new_email(
      to: email,
      from: @from,
      subject: "New enquiry received",
      html_body: "<strong> You have received an enquiry from #{user_name}. </strong>",
      html_body: "You can view your enquiries in your enquiries folder."
    )
  end

  def enquiry_update_email_business(user_name, email) do
    new_email(
      to: email,
      from: @from,
      subject: "Enquiry has been updated",
      html_body: "<strong> #{user_name} has updated an enquiry they sent you. </strong>",
      html_body: "You can view your enquiries in your enquiries folder."
    )
  end

  def enquiry_update_email_user(business_name, email) do
    new_email(
      to: email,
      from: @from,
      subject: "Enquiry updated",
      html_body: "<strong> Thank you for updating your enquiry to #{business_name}. </strong>",
      html_body: "You can view your completed enquiries in your enquiries folder."
    )
  end
end
