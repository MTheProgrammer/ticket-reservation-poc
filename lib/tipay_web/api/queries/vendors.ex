defmodule TipayWeb.Api.Queries.Vendors do
  @moduledoc """
  Vendors GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.VendorsResolver

  object :vendor_queries do
    @desc "Get all Vendors"
    field :all_vendors, non_null(list_of(non_null(:vendor))) do
      resolve(&VendorsResolver.all_vendors/3)
    end

    @desc "Get current user Vendors"
    field :my_vendors, non_null(list_of(non_null(:vendor))) do
      resolve(&VendorsResolver.my_vendors/3)
    end

    @desc "Returns Vendor available to edit by the current user"
    field :get_my_vendor, non_null(:vendor_query_result) do
      arg(:vendor_id, non_null(:id))

      resolve(&VendorsResolver.get_my_vendor/3)
    end
  end
end
