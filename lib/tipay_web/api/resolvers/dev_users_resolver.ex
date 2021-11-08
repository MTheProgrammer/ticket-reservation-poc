defmodule TipayWeb.Api.Resolvers.DevUsersResolver do
  @moduledoc """
  Dev: Users GraphQL Resolver
  """
  alias Tipay.Users

  def dev_request_user_password_reset(_root, %{email: email}, _info) do
    case Users.create_reset_password_token(email) do
      {:ok, token} -> {:ok, %{success: true, email: email, token: token}}
      {:error, _} -> {:ok, %{success: true, email: email}}
    end
  end
end
