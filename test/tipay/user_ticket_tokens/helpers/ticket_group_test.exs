defmodule Tipay.UserTicketTokens.Helpers.TicketGroupTest do
  use Tipay.DataCase, async: true

  alias Tipay.Tickets.Ticket
  alias Tipay.UserTicketTokens.Helpers.TicketGroup

  describe "user_ticket_tokens::helpers" do
    test "group_tickets_by_offer/1 adds tickets from the list to separate offer key" do
      expected_group_count = 2
      [offer_a, offer_b] = insert_list(expected_group_count, :offer)
      tickets = insert_list(2, :ticket, offer: offer_a) ++ insert_list(3, :ticket, offer: offer_b)

      result = TicketGroup.group_tickets_by_offer(tickets)
      assert expected_group_count == Enum.count(result)

      assert [
               %{
                 id: _,
                 name: _,
                 tickets: [
                   %Ticket{id: _},
                   %Ticket{id: _}
                 ]
               }
               | _tail
             ] = result
    end
  end
end
