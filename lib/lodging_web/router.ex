defmodule LodgingWeb.Router do
  use LodgingWeb, :router

  alias LodgingWeb.Plugs.{Auth, Guest, User, Business}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug(Auth)
  end

  pipeline :guest do
    plug(Guest)
  end

  pipeline :user do
    plug(Auth)
    plug(User)
  end

  pipeline :business do
    plug(Auth)
    plug(Business)
  end

  scope "/", LodgingWeb do
    pipe_through :browser

    get("/", SessionController, :new)
    post("/", SessionController, :create)
    get("/registeruser", AccountController, :new)
    post("/registeruser", AccountController, :create)
    get("/registerbusiness", BusinessController, :new)
    post("/registerbusiness", BusinessController, :create)
  end

  scope "/", LodgingWeb do
    pipe_through [:browser, :guest]
    get("/:user_id/verifyuser", AccountController, :verify_email)
    get("/:business_id/verifybusiness", BusinessController, :verify_email)
  end

  scope "/", LodgingWeb do
    pipe_through :browser

    get("/:user_id/verificationuser", AccountController, :send_email_verification)
    get("/:business_id/verificationbusiness", BusinessController, :send_email_verification)
  end

  scope "/", LodgingWeb do
    pipe_through [:browser, :auth]
    get("/logout", SessionController, :delete)
  end

  # User scope
  scope "/user", LodgingWeb do
    pipe_through [:browser, :user]

    get("/:user_id/home", UserController, :home)
    get("/:user_id/listings", UserController, :view_listings)
    get("/:user_id/listings/:listing_id/listing", UserController, :open_listing)
    get("/:user_id/listings/:listing_id/listing/enquire", UserController, :enquire_listing)
    get("/:user_id/enquiries", UserController, :view_enquiries)
    get("/:user_id/enquiries/:enquiry_id/enquiry", UserController, :open_enquiry)
    get("/:user_id/enquiries/:enquiry_id/enquiry/edit", UserController, :edit_enquiry)
    put("/:user_id/enquiries/:enquiry_id/enquiry/edit", UserController, :update_enquiry)
  end

  # Business scope
  scope "/business", LodgingWeb do
    pipe_through [:browser, :business]

    get("/:business_id/index", ListingController, :home)
    get("/:business_id/addnewlisting", ListingController, :add_new_listing)
    get("/:business_id/listings", ListingController, :view_all_listings)
    get("/:business_id/listing/:listing_id/edit", ListingController, :edit_listing)
    put("/:business_id/listing/:listing_id/edit", ListingController, :update_listing)
    get("/:business_id/listing/:listing_id/delete", ListingController, :delete_listing)
    get("/:business_id/enquiries", ListingController, :view_enquiries)
    get("/:business_id/enquiries/:enquiry_id/enquiry", ListingController, :view_enquiry)
  end

  scope "/business", LodgingWeb do
    pipe_through :browser

    get "/:business_id/listing/:listing_id/edit/uploads/image", ImageController, :new
    post "/:business_id/listing/:listing_id/edit/uploads/image", ImageController, :create
    get "/:business_id/listing/:listing_id/edit/uploads/image/:id", ImageController, :index
  end
end
