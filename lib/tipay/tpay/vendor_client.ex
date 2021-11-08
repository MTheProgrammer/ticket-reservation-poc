defmodule Tipay.Tpay.VendorClient do
  @moduledoc """
  This module performs requests to TPay API using Vendor credentials.
  Each Vendor has it's own account which is created by Admin Account.
  """

  alias Tipay.Tpay.Credentials
  alias Tipay.Vendors.Vendor
  alias Tipay.VendorsTpay
  alias TpayApi.Authorization.Response.Token
  alias TpayApi.Authorization.Auth
  alias TpayApi.HttpClient

  def execute(request, %Vendor{id: vendor_id}) do
    execute(request, vendor_id)
  end

  def execute(request, vendor_id) when is_binary(vendor_id) do
    bearer_token =
      with %Credentials{} = credentials <- VendorsTpay.get_vendor_credentials(vendor_id),
           {:ok, %Token{access_token: token}} <- get_bearer_token(credentials) do
        token
      else
        _ -> {:error, "Vendor has invalid or not configured credentials"}
      end

    TpayApi.HttpClient.execute(request, bearer_token)
  end

  @spec get_bearer_token(%Credentials{}) :: {:ok, %Token{}} | {:error, String.t()}
  defp get_bearer_token(%Credentials{api_key: api_key, api_password: api_password}) do
    auth =
      Auth.new(%{
        client_id: api_key,
        client_secret: api_password
      })

    result = HttpClient.execute(auth)

    case result do
      {:ok, body} -> {:ok, Token.from_response(body)}
      error -> error
    end
  end
end
