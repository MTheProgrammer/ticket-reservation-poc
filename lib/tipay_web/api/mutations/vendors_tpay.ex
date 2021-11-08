defmodule TipayWeb.Api.Mutations.VendorsTpay do
  @moduledoc """
  Vendors Tpay GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.VendorsTpayResolver

  object :vendors_tpay_mutations do
    @desc "Assign existing TPay credentials to Vendor."
    field :assign_tpay_credentials_to_vendor, non_null(:vendor_tpay_credentials_mutate_result) do
      arg(:vendor_tpay_credentials, non_null(:vendor_tpay_credentials_input))

      resolve(&VendorsTpayResolver.assign_tpay_credentials_to_vendor/3)
    end

    @desc "Register account for Vendor in TPay. Replaces original account."
    field :register_vendor_in_tpay, non_null(:vendor_tpay_credentials_mutate_result) do
      arg(:vendor_id, non_null(:id))
      arg(:account, non_null(:tpay_account_create_input))

      resolve(&VendorsTpayResolver.register_vendor/3)
    end
  end
end
