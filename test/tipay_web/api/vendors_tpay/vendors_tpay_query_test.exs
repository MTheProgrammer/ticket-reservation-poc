defmodule TipayWeb.Api.VendorsTpayQueryTest do
  @moduledoc """
  Vendors Tpay GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "VendorTpay query" do
    @get_vendor_tpay_credentials_query """
    query ($vendorId: ID!){
      getVendorTpayCredentials(vendorId: $vendorId) {
        apiKey
        apiPassword
        merchantId
      }
    }
    """

    test "get_vendor_tpay_credentials returns Vendor's Tpay credentials" do
      tpay_credentials = insert(:tpay_credentials, merchant_id: "123456")
      vendor_credentials = insert(:vendors_tpay_vendor_credentials, credentials: tpay_credentials)
      vendor = vendor_credentials.vendor

      vendor_user = insert(:vendor_user, vendor: vendor)
      user = vendor_user.user

      assert %{
               "getVendorTpayCredentials" => %{
                 "apiKey" => "testApiKey",
                 "apiPassword" => "testApiPassword",
                 "merchantId" => "123456"
               }
             } =
               query_with_user(@get_vendor_tpay_credentials_query, user, %{vendor_id: vendor.id})
    end
  end
end
