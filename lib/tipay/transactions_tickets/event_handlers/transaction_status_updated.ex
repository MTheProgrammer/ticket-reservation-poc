defmodule Tipay.TransactionsTickets.EventHandlers.TransactionStatusUpdated do
  alias Tipay.Transactions.Events.TransactionSubscriber
  alias Tipay.Transactions.Events.TransactionStatusUpdated
  alias Tipay.Tickets

  @behaviour TransactionSubscriber

  @impl TransactionSubscriber
  def execute(%TransactionStatusUpdated{
        transaction: %{offer_id: offer_id, user_id: user_id},
        status: status
      })
      when status === :paid do
    Tickets.issue_new_ticket(offer_id, user_id)
  end

  def execute(_), do: nil
end
