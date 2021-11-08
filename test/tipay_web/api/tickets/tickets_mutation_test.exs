defmodule TipayWeb.Api.TicketsMutationTest do
  @moduledoc """
  Tickets mutation GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "validate Ticket mutation" do
    @validate_ticket_mutation """
    mutation($userToken: ID!, $ticketIds: [ID!]!) {
      validateTickets(user_token: $userToken, ticket_ids: $ticketIds) {
        success
        errors
      }
    }
    """

    setup do
      %{vendor: vendor, user: usher} = insert(:vendor_user)
      event = insert(:event, vendor: vendor)
      offer = insert(:offer, event: event)
      %{user: ticket_user} = user_ticket_token = insert(:user_ticket_token)
      tickets = [insert(:ticket, status: :active, offer: offer, user: ticket_user)]

      [
        usher: usher,
        user_ticket_token: user_ticket_token,
        tickets: tickets,
        ticket_ids: Enum.map(tickets, fn %{id: id} -> id end)
      ]
    end

    test "validate active tickets returns success mutation",
         %{
           usher: usher,
           user_ticket_token: %{
             id: user_token
           },
           ticket_ids: ticket_ids
         } do
      mutation_args = %{
        user_token: user_token,
        ticket_ids: ticket_ids
      }

      assert %{
               "validateTickets" => %{
                 "errors" => nil,
                 "success" => true
               }
             } = mutate_with_user(@validate_ticket_mutation, usher, mutation_args)
    end

    test "validate not existing tickets returns error mutation",
         %{
           usher: usher,
           user_ticket_token: %{
             id: user_token
           }
         } do
      mutation_args = %{
        user_token: user_token,
        ticket_ids: ["de851708-7f7a-40e1-b8ec-da2baec30839"]
      }

      assert %{
               "validateTickets" => %{
                 "errors" => %{
                   "message" => "invalid ticket(s)",
                   "ticketIds" => ["de851708-7f7a-40e1-b8ec-da2baec30839"]
                 },
                 "success" => false
               }
             } = mutate_with_user(@validate_ticket_mutation, usher, mutation_args)
    end

    test "validate already validated tickets returns error mutation",
         %{
           usher: usher,
           user_ticket_token:
             %{
               id: token
             } = user_ticket_token,
           tickets: tickets,
           ticket_ids: ticket_ids
         } do
      Tipay.Tickets.validate_tickets(tickets, usher, user_ticket_token)

      mutation_args = %{
        user_token: token,
        ticket_ids: ticket_ids
      }

      assert %{
               "validateTickets" => %{
                 "errors" => %{
                   "id" => _,
                   "message" => %{
                     "ticketId" => "Ticket was already validated"
                   }
                 },
                 "success" => false
               }
             } = mutate_with_user(@validate_ticket_mutation, usher, mutation_args)
    end

    test "validate ticket for event which is not allowed for the Usher, returns error",
         %{
           user_ticket_token: %{
             id: user_token
           },
           ticket_ids: ticket_ids
         } do
      another_usher = insert(:user)

      mutation_args = %{
        user_token: user_token,
        ticket_ids: ticket_ids
      }

      assert %{
               "validateTickets" => %{
                 "errors" => %{
                   "message" => "you can't validate these ticket(s)",
                   "ticketIds" => [_]
                 },
                 "success" => false
               }
             } = mutate_with_user(@validate_ticket_mutation, another_usher, mutation_args)
    end
  end
end
