defmodule TipayWeb.Api.Queries.Transactions do
  @moduledoc """
  Transactions GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.TransactionsResolver

  object :transaction_queries do
    @desc "Get all available payment methods"
    field :all_payments, non_null(list_of(non_null(:payment_interface))) do
      resolve(&TransactionsResolver.all_payments/3)
    end

    @desc "Get User transaction by id"
    field :get_my_transaction, non_null(:transaction) do
      arg(:transaction_id, non_null(:id))

      resolve(&TransactionsResolver.get_my_transaction/3)
    end

    @desc "Get all transactions bound to the current user"
    field :my_transactions, non_null(list_of(non_null(:transaction))) do
      resolve(&TransactionsResolver.my_transactions/3)
    end
  end
end
