defmodule TpayApi.MoneyParser do
  @spec parse_amount!(any()) :: Decimal.t()
  def parse_amount!(amount) do
    case Decimal.cast(amount) do
      {:ok, value} -> value
      _ -> raise "failed to parse amount"
    end
  end
end
