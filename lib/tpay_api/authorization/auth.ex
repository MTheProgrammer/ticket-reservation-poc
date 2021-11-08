defmodule TpayApi.Authorization.Auth do
  @type t :: %__MODULE__{
          client_id: String.t(),
          client_secret: String.t()
        }
  @behaviour TpayApi.Request

  alias TpayApi.Authorization.Auth

  defstruct client_id: nil,
            client_secret: nil

  def endpoint, do: "/oauth/auth"

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  def to_api_payload(%Auth{} = request) do
    %{
      client_id: request.client_id,
      client_secret: request.client_secret
    }
  end
end
