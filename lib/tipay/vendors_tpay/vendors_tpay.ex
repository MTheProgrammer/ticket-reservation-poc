defmodule Tipay.VendorsTpay do
  @moduledoc """
  The Vendors Tpay bridge context.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.Tpay.Credentials
  alias Tipay.Vendors.Vendor
  alias Tipay.VendorsTpay.VendorCredentials

  alias TpayApi.Accounts.Create
  alias TpayApi.Accounts.Response.TransactionApiCredentials
  alias Tipay.Tpay.AdminClient

  defdelegate authorize(action, user, params), to: Tipay.VendorsTpay.CredentialsOwnerPolicy

  @doc """
  Stores Tipay credentials for Vendor.

  ## Examples

      iex> assign_credentials_to_vendor(%{field: value})
      {:ok, %VendorTpayCredentials{}}

      iex> assign_credentials_to_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def assign_credentials_to_vendor(%Credentials{id: credentials_id}, %Vendor{id: vendor_id}) do
    assign_credentials_to_vendor(credentials_id, vendor_id)
  end

  def assign_credentials_to_vendor(credentials_id, vendor_id) do
    %VendorCredentials{}
    |> VendorCredentials.changeset(%{vendor_id: vendor_id, credentials_id: credentials_id})
    |> Repo.insert()
  end

  @doc """
  Retrieves Tipay credentials for Vendor.
  """
  @spec get_vendor_credentials(%Vendor{} | binary()) :: %Credentials{} | nil
  def get_vendor_credentials(%Vendor{id: vendor_id}) do
    get_vendor_credentials(vendor_id)
  end

  def get_vendor_credentials(vendor_id) do
    with %VendorCredentials{credentials_id: credentials_id} <-
           Repo.get_by(VendorCredentials, vendor_id: vendor_id),
         %Credentials{} = credentials <- Tipay.Tpay.get_credentials_by_id(credentials_id) do
      credentials
    else
      _ -> nil
    end
  end

  def register(vendor_id, %{} = attrs) do
    account_create = Create.new(attrs)

    case AdminClient.execute(account_create) do
      {:ok, response} -> process_register_response(vendor_id, response)
      error -> error
    end
  end

  defp process_register_response(vendor_id, %{} = response) do
    try do
      transaction_api_credentials = TransactionApiCredentials.from_response(response)
      credentials_attrs = Map.from_struct(transaction_api_credentials)
      update_or_create_vendor_credentials(vendor_id, credentials_attrs)
    rescue
      # TODO: logger
      e ->
        {:error, :invalid_response}
    end
  end

  def update_or_create_vendor_credentials(%Vendor{id: vendor_id}, %{} = attrs) do
    update_or_create_vendor_credentials(vendor_id, attrs)
  end

  def update_or_create_vendor_credentials(vendor_id, %{} = attrs) do
    case get_vendor_credentials(vendor_id) do
      %Credentials{} = credentials ->
        update_credentials(credentials, vendor_id, attrs)

      nil ->
        create_credentials(vendor_id, attrs)
    end
  end

  defp update_credentials(%Credentials{} = credentials, %Vendor{}, %{} = attrs) do
    Tipay.Tpay.update_credentials(credentials, attrs)
  end

  defp create_credentials(vendor_id, %{} = attrs) do
    with {:ok, %Credentials{id: credentials_id} = credentials} <-
           Tipay.Tpay.create_credentials(attrs),
         {:ok, %VendorCredentials{}} <- assign_credentials_to_vendor(credentials_id, vendor_id) do
      {:ok, credentials}
    else
      {:error, error} -> {:error, error}
    end
  end
end
