defmodule Tipay.VendorsTest do
  use Tipay.DataCase, async: true

  alias Tipay.Vendors

  describe "vendors" do
    alias Tipay.Vendors.Vendor

    test "list_vendors/0 returns all vendors" do
      vendor = insert(:vendor)
      assert Vendors.list_vendors() == [vendor]
    end

    test "get_vendor!/1 returns the vendor with given id" do
      vendor = insert(:vendor)
      assert Vendors.get_vendor!(vendor.id) == vendor
    end

    test "create_vendor/1 with valid data creates a vendor" do
      vendor_desc = build(:vendor)

      assert {:ok, %Vendor{} = vendor} =
               Vendors.create_vendor(%{
                 name: vendor_desc.name,
                 description: vendor_desc.description,
                 address: vendor_desc.address,
                 opening_hours: vendor_desc.opening_hours,
                 active: vendor_desc.active
               })

      assert vendor.name == vendor_desc.name
      assert vendor.description == vendor_desc.description
      assert vendor.address == vendor_desc.address
      assert vendor.opening_hours == vendor_desc.opening_hours
      assert vendor.active == vendor_desc.active
    end

    test "create_vendor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vendors.create_vendor(%{})
    end

    test "update_vendor/2 with valid data updates the vendor" do
      vendor = insert(:vendor)
      vendor_desc = build(:vendor)

      assert {:ok, %Vendor{} = vendor} =
               Vendors.update_vendor(vendor, %{
                 name: vendor_desc.name,
                 description: vendor_desc.description,
                 address: vendor_desc.address,
                 opening_hours: vendor_desc.opening_hours
               })

      assert vendor.name == vendor_desc.name
      assert vendor.description == vendor_desc.description
      assert vendor.address == vendor_desc.address
      assert vendor.opening_hours == vendor_desc.opening_hours
    end

    test "update_vendor/2 with invalid data returns error changeset" do
      vendor = insert(:vendor)

      assert {:error, %Ecto.Changeset{}} =
               Vendors.update_vendor(vendor, %{
                 name: nil,
                 description: nil,
                 address: nil,
                 opening_hours: nil
               })

      assert vendor == Vendors.get_vendor!(vendor.id)
    end

    test "delete_vendor/1 deletes the vendor" do
      vendor = insert(:vendor)
      assert {:ok, %Vendor{}} = Vendors.delete_vendor(vendor)
      assert_raise Ecto.NoResultsError, fn -> Vendors.get_vendor!(vendor.id) end
    end

    test "change_vendor/1 returns a vendor changeset" do
      vendor = insert(:vendor)
      assert %Ecto.Changeset{} = Vendors.change_vendor(vendor)
    end
  end

  describe "vendors_users" do
    alias Tipay.Vendors.VendorUser

    @invalid_attrs %{}

    def vendor_user_fixture(attrs \\ %{}) do
      user = insert(:user)
      vendor = insert(:vendor)

      {:ok, vendor_user} =
        attrs
        |> Enum.into(%{user_id: user.id, vendor_id: vendor.id})
        |> Vendors.create_vendor_user()

      vendor_user
    end

    test "list_vendors_users/0 returns all vendors_users" do
      vendor_user = vendor_user_fixture()
      assert Vendors.list_vendors_users() == [vendor_user]
    end

    test "get_vendor_user!/1 returns the vendor_user with given id" do
      vendor_user = vendor_user_fixture()
      assert Vendors.get_vendor_user!(vendor_user.id) == vendor_user
    end

    test "create_vendor_user/1 with valid data creates a vendor_user" do
      user = insert(:user)
      vendor = insert(:vendor)

      assert {:ok, %VendorUser{}} =
               Vendors.create_vendor_user(%{vendor_id: vendor.id, user_id: user.id})
    end

    test "create_vendor_user/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Vendors.create_vendor_user(@invalid_attrs)

      assert %{user_id: ["can't be blank"], vendor_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "delete_vendor_user/1 deletes the vendor_user" do
      vendor_user = vendor_user_fixture()
      assert {:ok, %VendorUser{}} = Vendors.delete_vendor_user(vendor_user)
      assert_raise Ecto.NoResultsError, fn -> Vendors.get_vendor_user!(vendor_user.id) end
    end

    test "active?/1 for active vendor returns true" do
      %{id: vendor_id} = insert(:vendor, active: true)
      assert true == Vendors.active?(vendor_id)
    end

    test "active?/1 for inactive vendor returns false" do
      %{id: vendor_id} = insert(:vendor, active: false)
      assert false == Vendors.active?(vendor_id)
    end
  end
end
