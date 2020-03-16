defmodule LodgingWeb.CompanyController do
  use LodgingWeb, :controller

  alias Lodging.Accounts
  alias Lodging.Accounts.Business
  alias LodgingWeb.Endpoint

  def home(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)
    render(conn, "home.html", business: business)
  end

  def form(conn, %{"business_id" => business_id}) do
    business = Accounts.get_business!(business_id)
    render(conn, "company_form.html", business: business)
  end

  def sign_up(conn, %{"business_id" => business_id, "new_inputs" => new_inputs}) do
  end
end
