defmodule TpayApi.Transactions.Create do
  @type t :: %__MODULE__{
          amount: Decimal.t(),
          crc: String.t(),
          description: String.t(),
          hidden_description: String.t(),
          payer: TpayApi.Transactions.Structs.Payer.t(),
          callbacks: TpayApi.Transactions.Structs.Callbacks.t(),
          pay: TpayApi.Transactions.Structs.Pay.t()
        }
  @behaviour TpayApi.Request

  alias TpayApi.Transactions.Create
  alias TpayApi.Transactions.Structs.Callbacks
  alias TpayApi.Transactions.Structs.Pay
  alias TpayApi.Transactions.Structs.Payer

  defstruct amount: nil,
            crc: nil,
            description: nil,
            hidden_description: nil,
            payer: nil,
            callbacks: nil,
            pay: nil

  def endpoint, do: "/transactions"

  @spec new(data :: map()) :: t()
  def new(%{callbacks: callbacks, payer: payer, pay: pay} = data \\ %{}) do
    callbacks_struct = Callbacks.new(callbacks)
    payer_struct = Payer.new(payer)
    pay_struct = Pay.new(pay)

    creation_data =
      data
      |> Map.put(:callbacks, callbacks_struct)
      |> Map.put(:payer, payer_struct)
      |> Map.put(:pay, pay_struct)

    struct!(__MODULE__, creation_data)
  end

  def to_api_payload(%Create{} = request) do
    %{
      amount: request.amount,
      crc: request.crc,
      description: request.description,
      hiddenDescription: request.hidden_description,
      payer: Payer.to_api_payload(request.payer),
      callbacks: Callbacks.to_api_payload(request.callbacks),
      pay: Pay.to_api_payload(request.pay)
    }
  end
end
