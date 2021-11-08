defmodule TipayWeb.Api.Types.Transactions do
  @moduledoc """
  GraphQL Transactions types
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.TransactionsResolver

  @desc "Transaction Status determines what happened to the transaction"
  enum :transaction_status do
    value(:new)
    value(:pending)
    value(:paid)
    value(:fraud)
    value(:canceled)
  end

  @desc "Offer booked in transaction."
  object :transaction_offer_booking do
    field :id, non_null(:id)
    field :offer_id, non_null(:id)
    field :qty, non_null(:integer)

    field :offer, non_null(:offer) do
      resolve(&TransactionsResolver.offer_booking_offer/3)
    end
  end

  @desc "Transaction aggregates Offers requested to buy"
  object :transaction do
    field :id, non_null(:id)
    field :payment_method_id, non_null(:id)
    field :status, non_null(:transaction_status)
    field :offer_bookings, non_null(list_of(non_null(:transaction_offer_booking)))
  end

  @desc "Input for assigning Offer to Transaction."
  input_object :transaction_offer_booking_input do
    field :offer_id, non_null(:id)
    field :qty, non_null(:integer)
  end

  @desc "Input for creating Transaction mutation"
  input_object :transaction_create_input do
    field :payment_method_id, non_null(:id)
    field :accept_regulations, non_null(:boolean)
    field :offer_bookings, non_null(list_of(non_null(:transaction_offer_booking_input)))
  end

  object :transaction_payment do
    field :amount, non_null(:money)
    field :booking_to, non_null(:datetime)
    field :url, non_null(:string)
    field :transaction, non_null(:transaction)
  end

  @desc "Result of creating Transaction"
  object :create_transaction_result do
    field :success, non_null(:boolean)
    field :transaction_payment, :transaction_payment
    field :errors, :json
  end
end
