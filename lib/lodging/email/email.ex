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
end
