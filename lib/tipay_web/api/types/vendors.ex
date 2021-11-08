defmodule TipayWeb.Api.Types.Vendors do
  @moduledoc """
  GraphQL Vendors types
  """
  use Absinthe.Schema.Notation

  object :vendor do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :address, non_null(:string)
    field :opening_hours, non_null(:string)
    field :active, non_null(:boolean)
  end

  @desc "Input for creating Vendor mutation"
  input_object :vendor_create_input do
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :address, non_null(:string)
    field :opening_hours, non_null(:string)
    field :active, non_null(:boolean)
  end

  @desc "Input for editing Vendor mutation"
  input_object :vendor_edit_input do
    field :id, non_null(:id)
    field :name, :string
    field :description, :string
    field :address, :string
    field :opening_hours, :string
    field :active, :boolean
  end

  @desc "Result of executing Vendor mutation"
  object :vendor_mutate_result do
    field :success, non_null(:boolean)
    field :vendor, :vendor
    field :errors, :json
  end

  @desc "Result of querying Vendor"
  object :vendor_query_result do
    field :success, non_null(:boolean)
    field :vendor, :vendor
    field :errors, :json
  end
end
