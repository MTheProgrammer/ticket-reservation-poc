defmodule TipayWeb.Api.Resolvers.VendorsResolver do
  @moduledoc """
  Vendors GraphQL Resolver
  """
  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor
  alias Tipay.Vendors.VendorUser
  alias Tipay.Users.User

  def all_vendors(_root, _args, _info) do
    vendors = Vendors.list_active_vendors()
    {:ok, vendors}
  end

  def my_vendors(_root, _args, %{context: %{current_user: user}}) do
    vendors = Vendors.list_user_vendors(user)
    {:ok, vendors}
  end

  def get_my_vendor(_root, %{vendor_id: vendor_id}, %{context: %{current_user: %User{} = user}}) do
    result =
      get_vendor(vendor_id)
      |> permit_vendor(user)

    case result do
      {:ok, %Vendor{} = vendor} -> {:ok, %{success: true, vendor: vendor}}
      error -> error
    end
  end

  defp permit_vendor({:ok, %Vendor{} = vendor}, %User{} = user) do
    case Bodyguard.permit(Vendors, :view_my_vendor, user, vendor) do
      :ok -> {:ok, vendor}
      error -> error
    end
  end

  defp permit_vendor(error, _) do
    error
  end

  def create_vendor(_root, %{vendor: args}, %{context: %{current_user: %{id: user_id}}}) do
    with {:ok, %Vendor{id: vendor_id} = vendor} <- Vendors.create_vendor(args),
         {:ok, %VendorUser{}} <-
           Vendors.create_vendor_user(%{user_id: user_id, vendor_id: vendor_id}) do
      {:ok, %{success: true, vendor: vendor}}
    else
      error ->
        error
    end
  end

  def edit_my_vendor(_root, %{vendor: %{id: vendor_id} = args}, %{context: %{current_user: user}}) do
    args = Map.put(args, :user_id, user.id)

    result =
      vendor_id
      |> get_vendor()
      |> maybe_permit_edit(user)
      |> maybe_update_vendor(args)

    case result do
      {:ok, %Vendor{} = vendor} -> {:ok, %{success: true, vendor: vendor}}
      error -> error
    end
  end

  defp get_vendor(vendor_id) do
    case Vendors.get_vendor_by_id(vendor_id) do
      %Vendor{} = vendor -> {:ok, vendor}
      _ -> {:error, :not_found}
    end
  end

  defp maybe_permit_edit({:ok, %Vendor{} = vendor}, %User{} = user) do
    case Bodyguard.permit(Vendors, :edit_my_vendor, user, vendor) do
      :ok -> {:ok, vendor}
      _ -> {:error, :unauthorized}
    end
  end

  defp maybe_permit_edit(error, _) do
    error
  end

  defp maybe_update_vendor({:ok, %Vendor{} = vendor}, %{} = args) do
    Vendors.update_vendor(vendor, args)
  end

  defp maybe_update_vendor(error, _) do
    error
  end
end
