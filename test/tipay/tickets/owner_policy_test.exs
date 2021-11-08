defmodule Tipay.Tickets.OwnerPolicyTest do
  use Tipay.DataCase, async: true

  alias Tipay.Tickets.OwnerPolicy

  describe "tickets::owner_policy" do
    test "authorize/3 :view_event_tickets passes for Event which Vendor is bound to Usher" do
      %{vendor: vendor, user: usher} = insert(:vendor_user)
      %{id: event_id} = insert(:event, vendor: vendor)
      assert true === OwnerPolicy.authorize(:view_event_tickets, usher, event_id)
    end

    test "authorize/3 :view_event_tickets when Event's Vendor is not bound to Usher" do
      usher = insert(:user)
      %{id: event_id} = insert(:event)

      assert {:error, %{message: "you are not allowed to preview this event"}} =
               OwnerPolicy.authorize(:view_event_tickets, usher, event_id)
    end

    test "authorize/3 invalid action returns false" do
      assert false === OwnerPolicy.authorize(:invalid, 42, 999)
    end
  end
end
