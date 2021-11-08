defmodule TipayWeb.Api.VendorsMutationTest do
  @moduledoc """
  Vendors Tpay GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor

  describe "create a Vendor mutation" do
    @create_vendor_mutation """
    mutation($vendor: VendorCreateInput!) {
      createVendor(vendor: $vendor) {
        success
        vendor {
          id
          name
          description
          address
          openingHours
          active
        }
        errors
      }
    }
    """

    test "creates a new Vendor for logged in user" do
      user = insert(:user)
      _vendor = insert(:vendor)

      mutation_args = %{
        name: "Klub żźćπœę©ß←",
        description: "Najlepszy",
        address: "al. Jerozolimskie 123, 00-999 Warszawa",
        opening_hours: "20:00 - 04:00, pt-nd",
        active: true
      }

      assert %{
               "createVendor" => %{
                 "errors" => nil,
                 "success" => true,
                 "vendor" => %{
                   "id" => _,
                   "name" => "Klub żźćπœę©ß←",
                   "description" => "Najlepszy",
                   "address" => "al. Jerozolimskie 123, 00-999 Warszawa",
                   "openingHours" => "20:00 - 04:00, pt-nd",
                   "active" => true
                 }
               }
             } = mutate_with_user(@create_vendor_mutation, user, vendor: mutation_args)
    end

    test "creates a new Vendor for User and assigns User to Vendor" do
      user = insert(:user)
      _vendor = insert(:vendor)

      mutation_args = %{
        name: "Klub",
        description: "Najlepszy",
        address: "al. Jerozolimskie 123, 00-999 Warszawa",
        opening_hours: "20:00 - 04:00, pt-nd",
        active: true
      }

      assert %{
               "createVendor" => %{
                 "success" => true,
                 "vendor" => %{"id" => user_vendor_id}
               }
             } = mutate_with_user(@create_vendor_mutation, user, vendor: mutation_args)

      assert %Vendor{id: ^user_vendor_id} = Vendors.get_vendor_for_user(user, user_vendor_id)
    end
  end

  # TODO: test rejects editing vendor for different user
  describe "edit a Vendor mutation" do
    @edit_my_vendor_mutation """
    mutation($vendor: VendorEdit!) {
      editMyVendor(vendor: $vendor) {
        success
        vendor {
          id
          name
          description
          address
          openingHours
          active
        }
        errors
      }
    }
    """

    @valid_params %{
      name: "Electra Records",
      description: "American CD Company",
      address: "Some address",
      openingHours: "12-18",
      active: false
    }

    test "edits an existing Vendor for logged in user" do
      %{vendor: existing_vendor, user: user} = insert(:vendor_user)

      mutation_args =
        @valid_params
        |> Map.merge(%{id: existing_vendor.id})

      assert %{
               "editMyVendor" => %{
                 "errors" => nil,
                 "success" => true,
                 "vendor" => %{
                   "id" => _,
                   "name" => "Electra Records",
                   "description" => "American CD Company",
                   "address" => "Some address",
                   "openingHours" => "12-18",
                   "active" => false
                 }
               }
             } = mutate_with_user(@edit_my_vendor_mutation, user, vendor: mutation_args)
    end

    test "prevents editing an existing Vendor for different user" do
      existing_vendor = insert(:vendor)
      user = insert(:user)

      mutation_args =
        @valid_params
        |> Map.merge(%{id: existing_vendor.id})

      assert %{
               "editMyVendor" => %{
                 "errors" => %{msg: "unauthorized"},
                 "success" => false,
                 "vendor" => nil
               }
             } = mutate_with_user(@edit_my_vendor_mutation, user, vendor: mutation_args)
    end
  end
end
