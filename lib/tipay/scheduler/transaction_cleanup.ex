defmodule Tipay.Scheduler.TransactionCleanup do
  def work do
    expiry_time = Application.get_env(:tipay, :transaction_expiry_seconds)
    batch_size = Application.get_env(:tipay, :transaction_expiry_batch_size)

    Tipay.Transactions.cancel_outdated_transactions(
      expiry_time,
      batch_size
    )
  end
end
