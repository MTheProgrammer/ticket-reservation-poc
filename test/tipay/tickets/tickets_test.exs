defmodule Tipay.TicketsTest do
  use Tipay.DataCase, async: true

  alias Tipay.Tickets
  alias Tipay.Tickets.Ticket
  alias Tipay.Tickets.TicketValidation

  describe "tickets issuing" do
    test "issue_ticket/2 creates a new active Ticket for given Offer and User" do
      %{id: offer_id} = offer = insert(:offer)
      %{id: user_id} = user = insert(:user)

      assert {:ok, %Ticket{offer_id: ^offer_id, user_id: ^user_id, status: :active}} =
               Tickets.issue_new_ticket(offer, user)
    end
  end

  describe "tickets retrieval" do
    test "get_user_tickets_with_offers/1 returns tickets for the user who is bound to the ticket token" do
      [expected_ticket | _other_ticket] = insert_list(2, :ticket)
      %{user: user} = expected_ticket

      user_ticket_token = insert(:user_ticket_token, user: user)

      assert [%Ticket{} = result_ticket] = Tickets.get_user_tickets_by_token(user_ticket_token)
      assert result_ticket.id == expected_ticket.id
      assert result_ticket.offer.id == expected_ticket.offer.id
    end

    test "get_user_event_tickets_by_token/2 returns tickets for the User of a specific Event" do
      [expected_ticket | _other_ticket] = insert_list(2, :ticket)
      %{user: user, offer: offer} = expected_ticket

      %{
        event: %{
          id: event_id
        }
      } = offer

      user_ticket_token = insert(:user_ticket_token, user: user)

      assert [%Ticket{} = result_ticket] =
               Tickets.get_user_event_tickets_by_token(user_ticket_token, event_id)

      assert result_ticket.id == expected_ticket.id
      assert result_ticket.offer.id == expected_ticket.offer.id
    end

    test "get_ticket_validation/1 returns ticket validation for a given token" do
      %{ticket: ticket} = insert(:ticket_validation)

      assert %TicketValidation{} = Tickets.get_ticket_validation(ticket)
    end

    test "get_ticket_validation/1 returns nil if token has no validation" do
      ticket = insert(:ticket)

      assert nil == Tickets.get_ticket_validation(ticket)
    end
  end

  describe "tickets validation" do
    test "validate_tickets/3 with active tickets updates tickets status to validated" do
      %{id: usher_id} = usher = insert(:user)
      ticket = insert(:ticket, status: :active)
      %{user: ticket_user} = ticket
      %{id: used_ticket_token} = user_ticket_token = insert(:user_ticket_token, user: ticket_user)
      %{id: ticket_id} = ticket
      tickets = [ticket]

      Tickets.validate_tickets(tickets, usher, user_ticket_token)

      assert %Ticket{status: :validated} = Tickets.get_ticket_by_id(ticket_id)

      assert %TicketValidation{
               id: _,
               user_id: ^usher_id,
               used_token: ^used_ticket_token
             } = Tickets.get_ticket_validation(ticket)
    end

    test "validate_tickets/1 with already validated ticket throws exception" do
      usher = insert(:user)
      ticket = insert(:ticket, status: :active)
      %{user: ticket_user} = ticket
      user_ticket_token = insert(:user_ticket_token, user: ticket_user)
      tickets = [ticket]

      Tickets.validate_tickets(tickets, usher, user_ticket_token)

      assert {:error, :ticket_validation, %Ecto.Changeset{} = error_changeset, %{}} =
               Tickets.validate_tickets(
                 tickets,
                 usher,
                 user_ticket_token
               )

      assert %{
               ticket_id: ["Ticket was already validated"]
             } = errors_on(error_changeset)
    end
  end
end
