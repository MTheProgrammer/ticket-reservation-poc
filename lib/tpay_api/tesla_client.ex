defmodule TpayApi.TeslaClient do
  @tpay_base_url "https://api.tpay.com"

  @spec new() :: %Tesla.Client{}
  def new() do
    common_middleware()
    |> Tesla.client()
  end

  @spec new(String.t()) :: %Tesla.Client{}
  def new(token) do
    [{Tesla.Middleware.BearerAuth, token: token} | common_middleware()]
    |> Tesla.client()
  end

  defp common_middleware(base_url \\ @tpay_base_url) do
    [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"user-agent", "Tivent"}]},
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Retry,
       [
         delay: 500,
         max_retries: 10,
         max_delay: 4_000,
         should_retry: fn
           {:ok, %{status: status}} when status in [500] -> true
           {:ok, _} -> false
           {:error, _} -> true
         end
       ]}
    ]
  end
end
