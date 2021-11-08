defmodule TipayWeb.Api.Middleware.Authenticate do
  @moduledoc """
  GraphQL middleware for protected queries and mutations
  """
  @behaviour Absinthe.Middleware

  def call(res, _) do
    case res.context do
      %{current_user: %Tipay.Users.User{}} ->
        res

      _ ->
        Absinthe.Resolution.put_result(res, {:error, :unauthenticated})
    end
  end
end
