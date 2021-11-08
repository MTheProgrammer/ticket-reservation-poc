defmodule Tipay.Transactions.Events.EventBus do
  alias Tipay.Transactions.Transaction
  alias Tipay.Transactions.Transaction.Status
  alias Tipay.Transactions.Events.TransactionStatusUpdated

  alias Tipay.TransactionsTickets.EventHandlers.TransactionStatusUpdated,
    as: TransactionStatusUpdatedHandler

  @spec transaction_status_updated(%Transaction{}, Status.t()) :: any()
  def transaction_status_updated(
        %Transaction{} = transaction,
        status,
        event_handlers \\ [TransactionStatusUpdatedHandler]
      ) do
    Enum.map(event_handlers, fn event_handler ->
      event_handler.execute(%TransactionStatusUpdated{transaction: transaction, status: status})
      # TODO: handle event results
    end)
  end
end
