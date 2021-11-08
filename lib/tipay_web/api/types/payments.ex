defmodule TipayWeb.Api.Types.Payments do
  @moduledoc """
  GraphQL Payments types
  """
  use Absinthe.Schema.Notation

  @desc "Transaction payment definition. Payment has to be chosen by user before creating a transaction"
  interface :payment_interface do
    field :id, non_null(:id)
    field :label, non_null(:string)
    field :provider_code, non_null(:string)

    # TODO: instead of anonymous function, delgate it to another module
    # And create plugin-like system for introducing new payment types
    resolve_type(fn
      %{provider_code: :tpay}, _ -> :tpay_payment
      _, _ -> nil
    end)
  end
end
