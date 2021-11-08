defmodule Tipay.Users.ResetPasswordToken do
  @moduledoc """
  Reset Password schema and changeset
  """
  use Tipay.Schema
  import Ecto.Changeset
  alias Tipay.Users.ResetPasswordToken

  schema "reset_password_token" do
    field :token, :string
    belongs_to :user, Tipay.Users.User

    timestamps()
  end

  @doc false
  def changeset(%ResetPasswordToken{} = reset_password_token, attrs) do
    reset_password_token
    |> cast(attrs, [:token, :user_id])
    |> validate_required([:token, :user_id])
    |> unique_constraint(:user_id)
  end
end
