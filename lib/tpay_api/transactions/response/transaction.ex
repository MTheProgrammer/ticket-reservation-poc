defmodule TpayApi.Transactions.Response.Transaction do
  @type t :: %__MODULE__{
          transaction_payment_url: String.t(),
          amount: Decimal.t()
        }
  alias TpayApi.Transactions.Response.Transaction
  alias TpayApi.MoneyParser

  defstruct transaction_payment_url: nil,
            amount: nil

  def from_response(%{
        "transactionPaymentUrl" => transaction_payment_url,
        "amount" => amount
      }) do
    %Transaction{
      transaction_payment_url: transaction_payment_url,
      amount: MoneyParser.parse_amount!(amount)
    }
  end

  def from_response(_), do: raise("unable to process response")
end
