defmodule Tipay.Vendors.OwnerPolicy do
  @moduledoc """
  Vendors owner policy
  """
  @behaviour Bodyguard.Policy

  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor
  alias Tipay.Users.User

  def authorize(action, %User{} = user, %Vendor{id: vendor_id})
      when action in [:edit_my_vendor, :view_my_vendor] do
    case Vendors.get_vendor_for_user(user, vendor_id) do
      %Vendor{} -> true
      _ -> {:error, %{message: get_error_message(action)}}
    end
  end

  def authorize(_, _, _), do: false

  defp get_error_message(action) do
    "you are not allowed to #{action_error_message(action)} this vendor"
  end

  defp action_error_message(action) when action == :view_my_vendor, do: "view"
  defp action_error_message(_), do: "modify"
end
