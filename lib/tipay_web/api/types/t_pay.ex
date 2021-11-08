defmodule TipayWeb.Api.Types.TPay do
  @moduledoc """
  GraphQL TPay types
  """
  use Absinthe.Schema.Notation

  @desc "TPay Payment definition for transaction."
  object :tpay_payment do
    field :id, non_null(:id)
    field :label, non_null(:string)
    field :provider_code, non_null(:string)

    interface(:payment_interface)
  end
end
