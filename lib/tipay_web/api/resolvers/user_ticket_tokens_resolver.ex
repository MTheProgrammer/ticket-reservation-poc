defmodule TipayWeb.Api.Resolvers.UserTicketTokensResolver do
  @moduledoc """
  User Ticket Tokens GraphQL Resolver
  """
  alias Tipay.UserTicketTokens
  alias Tipay.Users.User

  def user_ticket_tokens(%User{} = parent, _args, _info) do
    user_ticket_tokens = UserTicketTokens.list_user_ticket_tokens(parent)

    {:ok, user_ticket_tokens}
  end
end
