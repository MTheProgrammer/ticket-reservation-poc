defmodule TpayApi.Transactions.Structs.Payer do
  @type t :: %__MODULE__{
          email: String.t(),
          name: String.t()
        }

  alias TpayApi.Transactions.Structs.Payer

  defstruct email: nil,
            name: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  def to_api_payload(%Payer{} = request) do
    %{
      email: request.email,
      name: request.name
    }
  end

  def to_api_payload(_), do: nil
end
