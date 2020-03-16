defmodule Lodging.Mailer do
  @moduledoc """
  The mailer module for Lodging that sends out emails. Uses the Bamboo library.
  """

  use Bamboo.Mailer, otp_app: :lodging
end
