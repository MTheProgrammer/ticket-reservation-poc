defmodule TipayWeb.Api.Queries.VendorsTpay do
  @moduledoc """
  Vendors Tpay GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.VendorsTpayResolver

  @desc "Retrieve Tpay Credentials for Vendor. Returns null if credentials were not defined before."
  object :vendors_tpay_queries do
    @desc "Get credentials for current Vendor"
    field :get_vendor_tpay_credentials, non_null(:tpay_credentials) do
      arg(:vendor_id, non_null(:id))
      resolve(&VendorsTpayResolver.get_vendor_tpay_credentials/3)
    end
  end
end
