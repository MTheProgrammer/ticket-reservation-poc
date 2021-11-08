defmodule TpayApi.Request do
  @callback endpoint() :: String.t()
  @callback to_api_payload(struct :: term()) :: map() | list()
end
