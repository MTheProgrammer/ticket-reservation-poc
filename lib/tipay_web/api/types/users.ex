defmodule TipayWeb.Api.Types.Users do
  @moduledoc """
  GraphQL User types
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.UserTicketTokensResolver

  object :user do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :nick, non_null(:string)
    field :has_accepted_terms, non_null(:boolean)

    field :ticket_tokens, non_null(list_of(non_null(:user_ticket_token))) do
      resolve(&UserTicketTokensResolver.user_ticket_tokens/3)
    end
  end

  object :user_token do
    field :token, non_null(:string)
  end

  @desc "Input for creating User mutation"
  input_object :user_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :password_confirmation, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :nick, non_null(:string)
    field :has_accepted_terms, non_null(:boolean)
  end

  @desc "Result of executing User mutation"
  object :user_mutate_result do
    field :success, non_null(:boolean)
    field :user, :user
    field :errors, :json
  end

  @desc "Login result. Returns token on success. If credentials do not match then `bad request` is returned in errors key"
  object :user_login_result do
    field :success, non_null(:boolean)
    field :token, :string
    field :errors, :json
  end

  @desc "Input for editing current User mutation"
  input_object :user_edit_input do
    field :first_name, :string
    field :last_name, :string
  end

  @desc "Result of executing request User password reset mutation"
  object :request_user_password_reset_result do
    field :success, non_null(:boolean)
    field :email, non_null(:string)
    field :errors, :json
  end

  @desc "Input for resetting current User mutation"
  input_object :reset_user_password_input do
    field :email, non_null(:string)
    field :token, non_null(:string)
    field :password, non_null(:string)
    field :password_confirmation, non_null(:string)
  end

  @desc "Result of executing password reset mutation"
  object :reset_user_password_result do
    field :success, non_null(:boolean)
    field :email, non_null(:string)
    field :errors, :json
  end
end
