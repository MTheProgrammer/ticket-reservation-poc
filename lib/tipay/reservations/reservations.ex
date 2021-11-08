defmodule Tipay.Reservations do
  @moduledoc """
  The Reservations context.
  """

  import Ecto.Query, warn: false

  alias Tipay.Transactions
  alias Tipay.Transactions.Transaction
  alias Tipay.Reservations.TransactionPayment
  alias Tipay.Reservations.TransactionConverter
  alias TpayApi.Transactions.Response.Transaction, as: ResponseTransaction
  alias Tipay.Tpay.VendorClient

  @doc """
  Reserves offers and publishes request to TPay.
  """
  def reserve(attrs \\ %{}) do
    with {:ok, %Transaction{} = transaction} <- Transactions.reserve(attrs),
         %ResponseTransaction{transaction_payment_url: url, amount: amount} <-
           reserve_transaction_in_tpay(transaction) do
      transaction_payment =
        TransactionPayment.new(%{
          url: url,
          amount: amount,
          booking_to: Transaction.get_booking_to(transaction),
          transaction: transaction
        })

      {:ok, transaction_payment}
    end
  end

  defp reserve_transaction_in_tpay(%Transaction{vendor_id: vendor_id} = transaction) do
    tpay_transaction_attrs = TransactionConverter.transaction_to_tpay_transaction(transaction)
    create_transaction = TpayApi.Transactions.Create.new(tpay_transaction_attrs)

    case VendorClient.execute(create_transaction, vendor_id) do
      {:ok, response} -> process_create_transaction_response(response)
      error -> error
    end
  end

  defp process_create_transaction_response(%{} = response) do
    try do
      TpayApi.Transactions.Response.Transaction.from_response(response)
    rescue
      # TODO: logger
      e ->
        {:error, :invalid_response}
    end
  end
end
