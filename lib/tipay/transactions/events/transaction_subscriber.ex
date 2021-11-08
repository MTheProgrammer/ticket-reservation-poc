defmodule Tipay.Transactions.Events.TransactionSubscriber do
  @moduledoc """
  Behaviour for Transaction events subscribers
  """

  alias Tipay.Transactions.Events.TransactionStatusUpdated

  @callback execute(%{} | %TransactionStatusUpdated{}) :: :ok | {:error, String.t()}
end
