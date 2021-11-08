defmodule Tipay.Transactions.Events.TransactionStatusUpdated do
  @type t :: %__MODULE__{
          transaction: %Tipay.Transactions.Transaction{},
          status: Tipay.Transactions.Transaction.Status.t()
        }

  defstruct transaction: nil,
            status: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end
end
