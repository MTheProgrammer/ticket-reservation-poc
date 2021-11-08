defmodule TipayWeb.Api.Queries.Users do
  @moduledoc """
  Users GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.UsersResolver

  object :user_queries do
    @desc "Get current user data"
    field :my_user, non_null(:user) do
      resolve(&UsersResolver.my_user/3)
    end

    @desc "Validate reset password token"
    field :check_reset_password_token, non_null(:boolean) do
      arg(:email, non_null(:string))
      arg(:token, non_null(:string))

      resolve(&UsersResolver.check_reset_password_token/3)
    end
  end
end
