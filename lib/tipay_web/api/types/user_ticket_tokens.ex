defmodule TipayWeb.Api.Types.UserTicketTokens do
  @moduledoc """
  GraphQL UserTicketTokens types
  """
  use Absinthe.Schema.Notation

  enum :user_ticket_token_status do
    value(:active)
    value(:inactive)
  end

  @desc "User Ticket Token"
  object :user_ticket_token do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :status, non_null(:user_ticket_token_status)
    field :inserted_at, non_null(:datetime)
  end
end
