defmodule TipayWeb.Api.Mutations.Users do
  @moduledoc """
  Users GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.UsersResolver

  object :user_mutations do
    @desc "Register new Admin User."
    field :create_user, non_null(:user_mutate_result) do
      arg(:user, non_null(:user_input))

      resolve(&UsersResolver.create_user/3)
    end

    @desc "Edit current logged in User."
    field :edit_my_user, non_null(:user_mutate_result) do
      arg(:user, non_null(:user_edit_input))

      resolve(&UsersResolver.edit_my_user/3)
    end

    @desc "Login Admin User."
    field :login, non_null(:user_login_result) do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UsersResolver.login/3)
    end

    @desc "Change current Admin User password."
    field :change_my_user_password, non_null(:user_mutate_result) do
      arg(:password, non_null(:string))
      arg(:password_confirmation, non_null(:string))
      arg(:current_password, non_null(:string))

      resolve(&UsersResolver.change_my_user_password/3)
    end

    @desc "Request Admin User password reset."
    field :request_user_password_reset, non_null(:request_user_password_reset_result) do
      arg(:email, non_null(:string))

      resolve(&UsersResolver.request_user_password_reset/3)
    end

    @desc "Reset user password if provided token is valid."
    field :reset_user_password, non_null(:reset_user_password_result) do
      arg(:reset_user_password, non_null(:reset_user_password_input))

      resolve(&UsersResolver.reset_password/3)
    end
  end
end
