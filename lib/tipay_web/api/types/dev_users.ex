defmodule TipayWeb.Api.Types.DevUsers do
  @moduledoc """
  Dev: GraphQL User types
  """
  use Absinthe.Schema.Notation

  @desc "Dev: Result of executing request User password reset mutation"
  object :dev_request_user_password_reset_result do
    field :success, non_null(:boolean)
    field :email, non_null(:string)
    field :token, :string
    field :errors, :json
  end
end
