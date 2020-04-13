defmodule Lodging.Accounts.Business do
  @moduledoc """
  Defines the schema for a business.
  """

  use Ecto.Schema

  import Ecto.Changeset
  alias Lodging.Accounts.Encryption
  alias Lodging.Accounts.Listing
  @missing_field "Please fill in this field."

  @primary_key {:id, :binary_id, auto_generate: false}
  schema "businesses" do
    field :username, :string, null: false
    field :name, :string, null: false
    field :lastname, :string, null: false
    field :email_address, :string, null: false
    field :business_name, :string, null: false
    field :business_address, :string, null: false
    field :business_number, :string
    field :accommodation, :boolean
    field :catering, :boolean
    field :events, :boolean
    field :account_type, :string
    field :terms_and_conditions, :boolean
    field :verified, :boolean

    field :password, :string, null: false, virtual: true
    field :password_confirmation, :string, null: false, virtual: true
    field :encrypted_password, :string

    has_many :listings, Listing

    timestamps()
  end

  def changeset(%__MODULE__{} = business, changes \\ %{}) do
    business
    |> cast(changes, [
      :username,
      :name,
      :lastname,
      :email_address,
      :business_name,
      :business_address,
      :business_number,
      :accommodation,
      :catering,
      :events,
      :password,
      :password_confirmation,
      :account_type,
      :terms_and_conditions,
      :verified,
      :id
    ])
    |> validate_required(
      [
        :username,
        :name,
        :lastname,
        :email_address,
        :business_name,
        :business_address,
        :business_number,
        :accommodation,
        :catering,
        :events,
        :password,
        :password_confirmation,
        :account_type,
        :terms_and_conditions,
        :verified,
        :id
      ],
      message: "Did you forget this one?"
    )
    |> unique_constraint(:email_address)
    |> unique_constraint(:username)
    |> validate_username()
    |> validate_name()
    |> validate_last_name()
    |> validate_email()
    |> validate_business_name()
    |> validate_business_number()
    |> validate_password()
    |> encrypt_password()
    |> validate_required(:encrypted_password)
  end

  def verified_changeset(user, attrs) do
    user
    |> cast(attrs, [:verified])
    |> validate_required([:verified])
  end

  defp validate_password(%{changes: %{password: password}} = changeset) do
    # Check length and content and return only 1 error even if both fails.
    length = String.length(password) > 7
    content = String.match?(password, ~r/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/)

    case {length, content} do
      {false, _} ->
        add_error(changeset, :password, "Minimum 8 characters.")

      {_, false} ->
        add_error(
          changeset,
          :password,
          "One upper-case letter, one lower-case letter and a number."
        )

      {true, true} ->
        validate_confirmation(changeset, :password, message: "Password entered incorrectly.")
    end
  end

  defp validate_password(changeset), do: changeset

  # Validate that email format is correct
  defp validate_email(%{changes: %{email_address: _}} = changeset) do
    changeset
    |> validate_format(:email_address, ~r/[^@]+@[^\.]+\..+/,
      message: "Please enter valid email address."
    )
    |> unique_constraint(:email_address, message: "Email address already exists")
  end

  defp validate_email(changeset), do: changeset

  # validate that username format is correct
  defp validate_username(%{changes: %{username: username}} = changeset) do
    changeset = downcase_username(changeset)
    username = String.downcase(username)

    length = String.length(username)
    format = String.match?(username, ~r/^[a-z[:alnum:]]+$/)

    case {length >= 7 && length <= 20, format} do
      {false, _} ->
        add_error(changeset, :username, "Please enter username between 8 and 19 characters.")

      {_, false} ->
        add_error(changeset, :username, "Username format is incorrect.")

      {true, true} ->
        unique_constraint(changeset, :username, message: "Username already exists.")
    end
  end

  # Only called if username is not in changeset
  defp validate_username(changeset), do: changeset

  # Name validation
  defp validate_name(%{changes: %{name: _}} = changeset) do
    changeset
    |> validate_format(
      :name,
      ~r/^[a-zA-Z '.-]*$/
    )
  end

  defp validate_name(changeset), do: changeset

  defp validate_last_name(%{changes: %{lastname: _}} = changeset) do
    changeset
    |> validate_format(
      :lastname,
      ~r/^[a-zA-Z '.-]*$/
    )
  end

  defp validate_last_name(changeset), do: changeset

  defp validate_business_name(%{changes: %{business_name: _}} = changeset) do
    changeset
    |> validate_format(
      :business_name,
      ~r/^[a-zA-Z '.-]*$/
    )
  end

  defp validate_business_name(changeset), do: changeset

  defp validate_business_number(%{changes: %{business_number: _}} = changeset) do
    changeset
    |> validate_format(
      :business_number,
      ~r/^[0-9()+\\s-]*$/
    )
  end

  defp validate_business_number(changeset), do: changeset

  defp encrypt_password(changeset) do
    password = get_change(changeset, :password)

    if password do
      encrypted_password = Encryption.hash_password(password)
      put_change(changeset, :encrypted_password, encrypted_password)
    else
      changeset
    end
  end

  defp downcase_username(changeset) do
    update_change(changeset, :username, &String.downcase/1)
  end
end
