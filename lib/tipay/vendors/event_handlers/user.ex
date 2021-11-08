defmodule Tipay.Vendors.EventHandlers.User do
  alias Tipay.Users.Events.UserSubscriber
  alias Tipay.Users.Events.UserCreated
  alias Tipay.UserTicketTokens.UserTicketToken
  alias Tipay.UserTicketTokens

  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor
  alias Tipay.Vendors.VendorUser

  @behaviour UserSubscriber

  @impl UserSubscriber
  def user_created(%UserCreated{user_id: user_id}) do
    {:ok, %Vendor{id: vendor_id}} =
      Vendors.create_vendor(%{
        name: "My Vendor",
        description: "Test Vendor",
        address: "Default Address",
        active: true,
        opening_hours: "12:00-13:30"
      })

    Vendors.create_vendor_user(%{vendor_id: vendor_id, user_id: user_id})
  end
end
