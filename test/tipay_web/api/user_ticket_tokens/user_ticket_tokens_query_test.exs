defmodule TipayWeb.Api.UserTicketTokensQueryTest do
  @moduledoc """
  User Ticket Tokens GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "query user ticket tokens in user object" do
    @user_ticket_tokens_query """
    {
      myUser {
        ticketTokens {
          id
          name
          status
          insertedAt
        }
      }
    }
    """

    setup do
      [
        user_ticket_token: insert(:user_ticket_token)
      ]
    end

    test "returns list of User's ticket tokens", %{
      user_ticket_token: %{user: user, id: id}
    } do
      assert %{
               "myUser" => %{
                 "ticketTokens" => [
                   %{
                     "id" => ^id,
                     "insertedAt" => _,
                     "name" => _,
                     "status" => _
                   }
                 ]
               }
             } = query_with_user(@user_ticket_tokens_query, user, %{})
    end
  end
end
