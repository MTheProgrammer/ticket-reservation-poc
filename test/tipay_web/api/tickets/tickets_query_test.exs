defmodule TipayWeb.Api.TicketsQueryTest do
  @moduledoc """
  Tickets GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "query tickets by user ticket token ID for Usher's vendor" do
    @tickets_query """
    query ($userToken: ID!, $eventId: ID!){
      userEventTickets(userToken: $userToken, eventId: $eventId) {
        user {
          firstName
          lastName
        }
        offers {
          id
          name
          tickets {
            id
            buyDate
            status
          }
        }
      }
    }
    """

    setup do
      %{vendor: vendor, user: usher} = insert(:vendor_user)
      event = insert(:event, vendor: vendor)
      offer = insert(:offer, event: event)
      user_ticket_token = insert(:user_ticket_token)
      %{user: user} = user_ticket_token

      [
        ticket: insert(:ticket, user: user, offer: offer),
        user_ticket_token: user_ticket_token,
        usher: usher
      ]
    end

    test "userEventTickets returns list of User's tickets grouped by offers", %{
      ticket: ticket,
      user_ticket_token: %{id: user_token},
      usher: usher
    } do
      %{offer: offer, id: ticket_id} = ticket
      %{event_id: event_id} = offer

      assert %{
               "userEventTickets" => %{
                 "user" => %{
                   "firstName" => _,
                   "lastName" => _
                 },
                 "offers" => [
                   %{
                     "id" => _,
                     "name" => _,
                     "tickets" => [
                       %{
                         "id" => ^ticket_id,
                         "buyDate" => _,
                         "status" => _
                       }
                     ]
                   }
                 ]
               }
             } =
               query_with_user(@tickets_query, usher, %{
                 user_token: user_token,
                 event_id: event_id
               })
    end
  end
end
