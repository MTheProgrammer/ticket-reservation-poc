defmodule TipayWeb.Api.Mutations.Vendors do
  @moduledoc """
  Vendors GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.VendorsResolver

  object :vendors_mutations do
    @desc "Create new Vendor and assign current user to it"
    field :create_vendor, non_null(:vendor_mutate_result) do
      arg(:vendor, non_null(:vendor_create_input))

      resolve(&VendorsResolver.create_vendor/3)
    end

    @desc "Edit current user Vendor - if one has permission to do so."
    field :edit_my_vendor, non_null(:vendor_mutate_result) do
      arg(:vendor, non_null(:vendor_edit_input))

      resolve(&VendorsResolver.edit_my_vendor/3)
    end
  end
end
