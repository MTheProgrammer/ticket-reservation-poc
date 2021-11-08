defmodule TpayApi.Transactions.Structs.Notification do
  @type t :: %__MODULE__{
          url: String.t(),
          email: String.t()
        }

  alias TpayApi.Transactions.Structs.Notification

  defstruct url: nil,
            email: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  def to_api_payload(%Notification{} = request) do
    %{
      url: request.url,
      email: request.email
    }
  end
end
