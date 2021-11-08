defmodule TipayWeb.Api.Types.VendorsTpay do
  @moduledoc """
  GraphQL Vendors Tpay types
  """
  use Absinthe.Schema.Notation

  @desc "Input for assigning Tpay Credentials to Vendor mutation"
  input_object :vendor_tpay_credentials_input do
    field :api_key, non_null(:string)
    field :api_password, non_null(:string)
    field :merchant_id, non_null(:string)
    field :vendor_id, non_null(:id)
  end

  @desc "TPay credentials object"
  object :tpay_credentials do
    field :api_key, non_null(:string)
    field :api_password, non_null(:string)
    field :merchant_id, non_null(:string)
  end

  @desc "Result of executing Vendor Tpay Credentials mutation"
  object :vendor_tpay_credentials_mutate_result do
    field :success, non_null(:boolean)
    field :tpay_credentials, :tpay_credentials
    field :errors, :json
  end

  @desc "Input for TPay Account registration"
  input_object :tpay_account_create_input do
    field :offer_code, :string
    field :email, non_null(:string)
    field :tax_id, :string
    field :regon, :string
    field :krs, :string
    field :legal_form, :integer
    field :category_id, :integer
    field :websites, non_null(list_of(non_null(:tpay_account_website_input)))
    field :addresses, non_null(list_of(non_null(:tpay_account_address_input)))
    field :persons, non_null(list_of(non_null(:tpay_account_person_input)))
  end

  input_object :tpay_account_website_input do
    field :name, non_null(:string)
    field :friendly_name, non_null(:string)
    field :description, non_null(:string)
    field :url, non_null(:string)
  end

  input_object :tpay_account_address_input do
    field :friendly_name, non_null(:string)
    field :name, non_null(:string)
    field :street, non_null(:string)
    field :house_number, non_null(:string)
    field :room_number, non_null(:string)
    field :postal_code, non_null(:string)
    field :city, non_null(:string)
    field :country, non_null(:string)
    field :phone, non_null(:string)
    field :is_main, non_null(:boolean)
    field :is_correspondence, non_null(:boolean)
    field :is_invoice, non_null(:boolean)
  end

  input_object :tpay_account_person_input do
    field :name, non_null(:string)
    field :surname, non_null(:string)
    field :is_representative, non_null(:boolean)
    field :is_contact_person, non_null(:boolean)
    field :contacts, non_null(list_of(non_null(:tpay_account_person_contact_input)))
  end

  input_object :tpay_account_person_contact_input do
    field :type, non_null(:integer)
    field :contact, non_null(:string)
  end
end
