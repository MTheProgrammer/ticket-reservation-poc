defmodule TpayApi.Transactions.Structs.Pay do
  @type t :: %__MODULE__{
          group_id: integer(),
          method: String.t()
        }

  alias TpayApi.Transactions.Structs.Pay

  defstruct group_id: nil,
            method: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  def to_api_payload(%Pay{} = request) do
    %{
      groupId: request.group_id,
      method: request.method
    }
  end

  def to_api_payload(_), do: nil
end
