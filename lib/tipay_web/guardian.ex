defmodule TipayWeb.Guardian do
  @moduledoc """
  Guardian configuration
  """
  use Guardian, otp_app: :tipay

  alias Tipay.Users
  alias Tipay.Users.User

  def subject_for_token(%User{} = user, _claims) do
    {:ok, user.id}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    claims["sub"]
    |> Users.get_user_by_id()
    |> case do
      nil -> {:error, nil}
      user -> {:ok, user}
    end
  end
end
