defmodule TipayWeb.Api.Resolvers.VendorsTpayResolver do
  @moduledoc """
  Vendors Tpay GraphQL Resolver
  """
  alias Tipay.Tpay.Credentials
  alias Tipay.Vendors
  alias Tipay.Vendors.Vendor
  alias Tipay.VendorsTpay

  def get_vendor_tpay_credentials(_root, %{vendor_id: vendor_id}, %{
        context: %{current_user: user}
      }) do
    case Vendors.get_vendor_for_user(user, vendor_id) do
      %Vendor{} = vendor ->
        case VendorsTpay.get_vendor_credentials(vendor) do
          %Credentials{} = credentials -> {:ok, credentials}
          _ -> {:error, message: "Vendor has no TPay Credentials assigned yet"}
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def assign_tpay_credentials_to_vendor(
        _root,
        %{vendor_tpay_credentials: %{vendor_id: vendor_id} = credentials_args},
        %{context: %{current_user: user}}
      ) do
    case Bodyguard.permit(Tipay.VendorsTpay, :modify_vendor_credentials, user, vendor_id) do
      :ok ->
        case VendorsTpay.update_or_create_vendor_credentials(vendor_id, credentials_args) do
          {:ok, credentials} -> {:ok, %{success: true, tpay_credentials: credentials}}
          {:error, _} = error -> error
        end

      {:error, _} = error ->
        error
    end
  end

  def register_vendor(
        _root,
        %{vendor_id: vendor_id, account: account},
        %{context: %{current_user: user}}
      ) do
    case Bodyguard.permit(Tipay.VendorsTpay, :modify_vendor_credentials, user, vendor_id) do
      :ok ->
        request_vendor_register(vendor_id, account)

      _ ->
        {:error, message: "Failed to register vendor."}
    end
  end

  defp request_vendor_register(vendor_id, account) do
    account_create_attrs = account_to_tpay_api_account_create_attrs(account)

    case VendorsTpay.register(vendor_id, account_create_attrs) do
      {:ok, credentials} -> {:ok, %{success: true, tpay_credentials: credentials}}
      error -> error
    end
  end

  defp account_to_tpay_api_account_create_attrs(%{} = attrs) do
    attrs
    |> rename_api_accounts_keys()
    |> remove_api_accounts_obsolete_keys()
  end

  defp account_to_tpay_api_account_create_attrs(_), do: raise("invalid request")

  defp rename_api_accounts_keys(%{websites: websites, addresses: addresses, persons: persons}) do
    %{
      website: websites,
      address: addresses,
      person: persons
    }
  end

  defp remove_api_accounts_obsolete_keys(%{} = attrs) do
    attrs
    |> Map.delete(:websites)
    |> Map.delete(:addresses)
    |> Map.delete(:persons)
  end
end
