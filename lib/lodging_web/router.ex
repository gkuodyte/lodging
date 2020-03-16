defmodule LodgingWeb.Router do
  use LodgingWeb, :router

  alias LodgingWeb.Plugs.{Auth, Guest, User, Verify, Business}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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
    #   get("/forgotpassword", AccountController, :forgotten_password)
    #   post("/forgotpassword", AccountController, :send_email_for_new_password)
    #   get("/changepassword", AccountController, :change_password)
    #   put("/changepassword", AccountController, :set_new_password)
  end

  scope "/", LodgingWeb do
    pipe_through [:browser, :guest]
    get("/:user_id/verifyuser", AccountController, :verify_email)
    get("/:business_id/verifybusiness", BusinessController, :verify_email)
  end

  # # Scope for verifying a new account
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
  scope "/", LodgingWeb do
    pipe_through [:browser, :user]

    get("/home", UserController, :home)
  end

  # Company scope
  scope "/", LodgingWeb do
    pipe_through [:browser, :business]

    get("/:business_id/index", CompanyController, :home)
    get("/:business_id/form", CompanyController, :form)
    post("/:business_id/form", CompanyController, :sign_up)
  end
end
