defmodule TipayWeb.Api.Resolvers.TransactionsResolver do
  @moduledoc """
  GraphQL Transactions resolver
  """
  alias Tipay.Offers
  alias Tipay.Transactions
  alias Tipay.Transactions.OfferBooking
  alias Tipay.Transactions.Transaction
  alias Tipay.Reservations.TransactionPayment

  def all_payments(_root, _args, _info) do
    payments = Transactions.list_payments_mock()
    {:ok, payments}
  end

  def my_transactions(_root, _args, %{context: %{current_user: user}}) do
    transactions = Transactions.get_user_transactions(user.id)

    {:ok, transactions}
  end

  def get_my_transaction(_root, %{transaction_id: transaction_id}, %{
        context: %{current_user: user}
      }) do
    with %Transaction{} = transaction <- Transactions.get_by_id(transaction_id),
         :ok <- Bodyguard.permit(Transactions, :view, user, transaction) do
      {:ok, transaction}
    end
  end

  def create_transaction(_root, %{transaction: args}, %{context: %{current_user: user}}) do
    params = Map.put(args, :user_id, user.id)

    case Tipay.Reservations.reserve(params) do
      {:ok, %TransactionPayment{} = transaction_payment} ->
        {:ok, %{success: true, transaction_payment: transaction_payment}}

      {:error, %Ecto.Changeset{} = error_changeset} ->
        {:error, error_changeset}

      {:error, error} ->
        {:error, %{msg: error}}
    end
  end

  # TODO: use data provider or different strategy
  # for resolving Offers in one query
  # (by figuring out which args are requested) - different resolving strategies
  def offer_booking_offer(%OfferBooking{} = parent, _args, _info) do
    offer = Offers.get_offer_by_id(parent.offer_id)

    {:ok, offer}
  end
end
