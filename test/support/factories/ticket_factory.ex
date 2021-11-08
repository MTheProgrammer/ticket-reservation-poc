defmodule Tipay.TicketFactory do
  @moduledoc """
  ExMachina Ticket factory
  """
  defmacro __using__(_opts) do
    quote do
      def ticket_factory do
        user = build(:user)
        offer = build(:offer)

        %Tipay.Tickets.Ticket{
          status: :active,
          user: user,
          offer: offer
        }
      end

      def ticket_validation_factory do
        user = build(:user)
        ticket = build(:ticket, status: :validated)
        %{id: token_id} = insert(:user_ticket_token)

        %Tipay.Tickets.TicketValidation{
          user: user,
          ticket: ticket,
          used_token: token_id
        }
      end
    end
  end
end
