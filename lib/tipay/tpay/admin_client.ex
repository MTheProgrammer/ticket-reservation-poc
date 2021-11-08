defmodule Tipay.Tpay.AdminClient do
  @moduledoc """
  Admin client performs request with global API key configured for the main TPay account.

  There are two methods of authorization - one for the client account creation - this is a global api token
  Another for transactions per vendor

  There are separate clients for transaction api and for account management.
  """
  alias TpayApi.HttpClient
  alias TpayApi.Authorization.Response.Token
  alias TpayApi.Authorization.Auth
  alias TpayApi.Config

  def execute(request) do
    case get_admin_bearer_token() do
      {:ok, %Token{access_token: token}} ->
        HttpClient.execute(request, token)

      {:error, _} ->
        {:error, %{message: "TPay Admin has invalid or not configured credentials"}}
    end
  end

  @spec get_admin_bearer_token() :: {:ok, %Token{}} | {:error, String.t()}
  defp get_admin_bearer_token() do
    auth =
      Auth.new(%{
        client_id: Config.api_key(),
        client_secret: Config.api_password()
      })

    result = HttpClient.execute(auth)

    case result do
      {:ok, body} -> {:ok, Token.from_response(body)}
      error -> error
    end
  end
end
