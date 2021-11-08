defmodule TipayWeb.Api.Types.Tickets do
  @moduledoc """
  GraphQL Ticket types
  """
  use Absinthe.Schema.Notation

  @desc "User tickets for a given Event"
  object :user_event_tickets do
    field :user, non_null(:user)
    field :offers, non_null(list_of(non_null(:offer_with_tickets)))
  end

  @desc "Ticket validity status"
  enum :ticket_status do
    value(:active)
    value(:validated)
  end

  @desc "Tickets aggregated by offer"
  object :offer_with_tickets do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :tickets, non_null(list_of(non_null(:ticket)))
  end

  @desc "Ticket for an Event"
  object :ticket do
    field :id, non_null(:id)
    field :buy_date, non_null(:datetime)
    field :status, non_null(:ticket_status)
  end

  @desc "Result of validating Tickets"
  object :ticket_validation_result do
    field :success, non_null(:boolean)
    field :errors, :json
  end
end
