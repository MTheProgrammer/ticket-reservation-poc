defmodule TipayWeb.Api.Mutations.Transactions do
  @moduledoc """
  Transactions GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.TransactionsResolver

  object :transaction_mutations do
    @desc "Create new transaction for offers purchase."
    field :create_transaction, non_null(:create_transaction_result) do
      arg(:transaction, non_null(:transaction_create_input))

      resolve(&TransactionsResolver.create_transaction/3)
    end
  end
end
