defmodule TpayApi.Accounts.Response.TransactionApiCredentials do
  @type t :: %__MODULE__{
          merchant_id: String.t(),
          api_key: String.t(),
          api_password: String.t()
        }
  alias TpayApi.Accounts.Response.TransactionApiCredentials

  defstruct merchant_id: nil,
            api_key: nil,
            api_password: nil

  def from_response(%{
        "transactionApiCredentials" => %{
          "merchantId" => merchant_id,
          "apiKey" => api_key,
          "apiPassword" => api_password
        }
      }) do
    %TransactionApiCredentials{
      merchant_id: Integer.to_string(merchant_id),
      api_key: api_key,
      api_password: api_password
    }
  end

  def from_response(_), do: raise("unable to process response")
end
