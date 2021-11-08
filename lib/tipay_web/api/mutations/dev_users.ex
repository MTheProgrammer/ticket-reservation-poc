defmodule TipayWeb.Api.Mutations.DevUsers do
  @moduledoc """
  Dev: Users GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.DevUsersResolver

  object :dev_user_mutations do
    @desc "DEV MUTATION: retrieve user password request token."
    field :dev_request_user_password_reset, non_null(:dev_request_user_password_reset_result) do
      arg(:email, non_null(:string))

      resolve(&DevUsersResolver.dev_request_user_password_reset/3)
    end
  end
end
