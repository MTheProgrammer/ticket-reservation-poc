defmodule Tipay.VendorsTpay.CredentialsOwnerPolicy do
  @moduledoc """
  Vendors Tpay owner policy grouped by Vendors
  """
  @behaviour Bodyguard.Policy

  alias Tipay.Users.User
  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor

  def authorize(action, %User{} = user, %Vendor{id: vendor_id}) do
    authorize(action, user, vendor_id)
  end

  def authorize(action, %User{} = user, vendor_id)
      when action in [:modify_vendor_credentials] do
    case Vendors.get_vendor_for_user(user, vendor_id) do
      %Vendor{} -> true
      _ -> {:error, %{message: "you are not allowed to modify this vendor's credentials"}}
    end
  end

  def authorize(_, _, _), do: false
end
