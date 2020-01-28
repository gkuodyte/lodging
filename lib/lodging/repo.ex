defmodule Lodging.Repo do
  use Ecto.Repo,
    otp_app: :lodging,
    adapter: Ecto.Adapters.Postgres
end
