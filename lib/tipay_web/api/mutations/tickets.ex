defmodule TipayWeb.Api.Mutations.Tickets do
  @moduledoc """
  Tickets GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.TicketsResolver

  object :ticket_mutations do
    @desc "Mark Tickets as validated."
    field :validate_tickets, non_null(:ticket_validation_result) do
      arg(:user_token, non_null(:id))
      arg(:ticket_ids, non_null(list_of(non_null(:id))))

      resolve(&TicketsResolver.validate_tickets/3)
    end
  end
end
