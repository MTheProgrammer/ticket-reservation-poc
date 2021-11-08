defmodule TipayWeb.Api.VendorsQueryTest do
  use TipayWeb.ApiCase, async: true

  @query """
  {
    allVendors {
      id
      name
    }
  }
  """

  setup do
    user = insert(:user)

    [user: user]
  end

  describe "vendors query" do
    test "returns list of existing active vendors", %{user: user} do
      _inactive_vendor = insert(:vendor, active: false)
      vendor = insert(:vendor, name: "GQL Test Vendor")
      vendor_id = "#{vendor.id}"

      assert %{
               "allVendors" => [
                 %{
                   "id" => ^vendor_id,
                   "name" => "GQL Test Vendor"
                 }
               ]
             } = query_with_user(@query, user, %{})
    end
  end

  @my_vendors_query """
  {
    myVendors {
      id
      name
      description
      address
      openingHours
      active
    }
  }
  """

  @get_my_vendor_query """
  query($vendorId: ID!) {
    getMyVendor(vendorId: $vendorId) {
      vendor {
        id
        name
        description
        address
        openingHours
        active
      }
      success
      errors
    }
  }
  """

  describe "user's vendors query" do
    setup do
      [vendor_user: insert(:vendor_user), another_vendor: insert(:vendor)]
    end

    test "returns list of all vendors belonging to specified user", %{
      vendor_user: %{vendor: %{id: expected_vendor_id}, user: user}
    } do
      assert %{
               "myVendors" => [
                 %{
                   "id" => ^expected_vendor_id,
                   "name" => _,
                   "description" => _,
                   "address" => _,
                   "openingHours" => _,
                   "active" => true
                 }
               ]
             } = query_with_user(@my_vendors_query, user, %{})
    end

    test "getMyVendor returns only Vendor for the current user", %{
      vendor_user: %{vendor: %{id: expected_vendor_id}, user: user}
    } do
      assert %{
               "getMyVendor" => %{
                 "vendor" => %{
                   "id" => ^expected_vendor_id,
                   "name" => _,
                   "description" => _,
                   "address" => _,
                   "openingHours" => _,
                   "active" => true
                 },
                 "success" => true,
                 "errors" => nil
               }
             } = query_with_user(@get_my_vendor_query, user, %{vendor_id: expected_vendor_id})
    end

    test "getMyVendor returns error if Vendor was not found for the current user", %{
      vendor_user: %{user: user}
    } do
      assert {:error, [%{message: "not_found", path: ["getMyVendor"]}]} =
               query_with_user(@get_my_vendor_query, user, %{vendor_id: "invalid-id"})
    end
  end
end
