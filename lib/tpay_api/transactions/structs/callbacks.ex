defmodule TpayApi.Transactions.Structs.Callbacks do
  @type t :: %__MODULE__{
          payer_urls: TpayApi.Transactions.Structs.PayerUrls.t(),
          notification: TpayApi.Transactions.Structs.Notification.t()
        }

  alias TpayApi.Transactions.Structs.Callbacks
  alias TpayApi.Transactions.Structs.Notification
  alias TpayApi.Transactions.Structs.PayerUrls

  defstruct payer_urls: nil,
            notification: nil

  @spec new(data :: map()) :: t()
  def new(%{notification: notification, payer_urls: payer_urls} = data \\ %{}) do
    creation_data =
      data
      |> Map.put(:notification, Notification.new(notification))
      |> Map.put(:payer_urls, PayerUrls.new(payer_urls))

    struct!(__MODULE__, creation_data)
  end

  def to_api_payload(%Callbacks{} = request) do
    %{
      payerUrls: PayerUrls.to_api_payload(request.payer_urls),
      notification: Notification.to_api_payload(request.notification)
    }
  end
end
