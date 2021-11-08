defmodule TpayApi.Transactions.Structs.PayerUrls do
  @type t :: %__MODULE__{
          success: String.t(),
          error: String.t()
        }

  alias TpayApi.Transactions.Structs.PayerUrls

  defstruct success: nil,
            error: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  def to_api_payload(%PayerUrls{} = request) do
    %{
      succes: request.success,
      error: request.error
    }
  end
end
