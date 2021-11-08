defmodule Tipay.Tickets.OwnerPolicy do
  @moduledoc """
  Tickets owner policy
  """
  @behaviour Bodyguard.Policy

  alias Tipay.Events
  alias Tipay.Events.Event
  alias Tipay.Users.User
  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor

  def authorize(action, %User{} = user, event_id)
      when action in [:view_event_tickets, :validate_event_tickets] and is_binary(event_id) do
    with %Event{vendor_id: event_vendor_id} <- Events.get_event_by_id(event_id),
         %Vendor{} <- Vendors.get_vendor_for_user(user, event_vendor_id) do
      true
    else
      _ -> {:error, %{message: "you are not allowed to preview this event"}}
    end
  end

  def authorize(_, _, _), do: false
end
