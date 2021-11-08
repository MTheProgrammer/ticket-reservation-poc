defmodule Tipay.Reservations.TransactionPayment do
  @type t :: %__MODULE__{
          amount: Money.t(),
          booking_to: DateTime.t(),
          url: String.t(),
          transaction: Tipay.Transactions.Transaction
        }

  defstruct amount: nil,
            booking_to: nil,
            url: nil,
            transaction: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{})

  def new(%{amount: %Decimal{} = decimal_amount} = data) do
    decimal_to_int =
      decimal_amount
      |> Decimal.mult(100)
      |> Decimal.round()
      |> Decimal.to_integer()

    create_data =
      data
      |> Map.put(:amount, %Money{amount: decimal_to_int})

    new(create_data)
  end

  def new(data) do
    struct!(__MODULE__, data)
  end
end
