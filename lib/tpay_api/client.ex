defmodule TpayApi.Client do
  @type request() :: map()
  @type token() :: String.t()

  @callback execute(request(), token()) :: {:ok, map()} | {:error, term()}
  @callback execute(request()) :: {:ok, map()} | {:error, term()}
end
