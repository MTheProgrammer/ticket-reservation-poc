defmodule Tipay.Users.User do
  @moduledoc """
  User schema and changeset
  """
  use Tipay.Schema
  import Ecto.Changeset
  alias Tipay.Users.User

  @required ~w(first_name last_name nick email has_accepted_terms)a
  @cast @required ++ ~w(nick password password_confirmation)a

  schema "users" do
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :nick, :string
    field :email, :string
    field :has_accepted_terms, :boolean

    # Virtual fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @cast)
    |> validate_required(@required)
    |> validate_length(:password, min: 6, max: 32)
    |> validate_acceptance(:has_accepted_terms, message: "please accept terms")
    |> unique_constraint(:email, downcase: true)
    |> unique_constraint(:nick, downcase: true)
    |> encrypt_password
    |> validate_confirmation(:password)
  end

  def update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end

  def update_password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation, :current_password])
    |> validate_required([:password, :password_confirmation, :current_password])
    |> validate_confirmation(:password)
    |> check_current_password(user)
    |> encrypt_password
  end

  def update_reseted_password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_confirmation(:password)
    |> encrypt_password
  end

  defp check_current_password(changeset, %User{} = user) do
    current_password = get_change(changeset, :current_password)

    case Bcrypt.check_pass(user, current_password) do
      {:ok, _} ->
        changeset

      _ ->
        add_error(changeset, :current_password, "invalid password")
    end
  end

  defp encrypt_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        change(changeset, Bcrypt.add_hash(password))
    end
  end
end
