defmodule TipayWeb.Api.Queries.Tickets do
  @moduledoc """
  Tickets GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.TicketsResolver

  object :ticket_queries do
    @desc "Returns user tickets for a given events. Validates Usher's permission for Event's Vendor"
    field :user_event_tickets, non_null(:user_event_tickets) do
      arg(:user_token, non_null(:id))
      arg(:event_id, non_null(:id))

      resolve(&TicketsResolver.user_event_tickets/3)
    end
  end
end
