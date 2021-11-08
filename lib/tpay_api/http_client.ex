defmodule TpayApi.HttpClient do
  @behaviour TpayApi.Client

  alias TpayApi.TeslaClient

  @spec execute(map(), String.t()) :: {:ok, map()} | {:error, term()}
  def execute(%module{} = request, bearer_token) do
    endpoint = module.endpoint()
    payload = module.to_api_payload(request)

    client = TeslaClient.new(bearer_token)
    generic_request(client, endpoint, payload)
  end

  def execute(%module{} = request) do
    endpoint = module.endpoint()
    payload = module.to_api_payload(request)

    client = TeslaClient.new()
    generic_request(client, endpoint, payload)
  end

  defp generic_request(client, endpoint, payload)
       when is_binary(endpoint) and is_map(payload) do
    Tesla.post(client, endpoint, payload)
    |> handle_response()
  end

  def handle_response({:ok, %Tesla.Env{status: 200, body: body}}), do: {:ok, body}

  def handle_response({:ok, %Tesla.Env{status: 500}}) do
    {:error, :internal_server_error}
  end

  def handle_response({:ok, %Tesla.Env{body: %{"errors" => errors}}}) do
    {:error, errors}
  end

  # TODO: log failed request - this is Tesla error
  def handle_response({:error, error}), do: {:error, error}
end
