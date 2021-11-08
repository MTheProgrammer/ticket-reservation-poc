defmodule Tipay.UserTicketTokens.Helpers.TicketGroup do
  alias Tipay.Tickets.Ticket
  alias Tipay.Offers.Offer

  @spec group_tickets_by_offer([%Ticket{}]) :: list(%{})
  def group_tickets_by_offer(tickets) do
    offer_tickets = Enum.group_by(tickets, &extract_ticket_offer_id/1)
    offers = get_unique_offers(tickets)

    Enum.map(offers, fn offer = %Offer{} -> bind_tickets_to_offer(offer, offer_tickets) end)
  end

  defp bind_tickets_to_offer(offer = %Offer{id: offer_id}, offer_tickets) do
    current_offer_tickets = offer_tickets[offer_id]
    Map.put_new(offer, :tickets, current_offer_tickets)
  end

  defp get_unique_offers(tickets) do
    tickets
    |> Enum.map(&extract_ticket_offer/1)
    |> Enum.uniq_by(&get_offer_id/1)
  end

  defp get_offer_id(%Offer{id: offer_id}), do: offer_id

  defp extract_ticket_offer(%Ticket{
         offer: %Offer{} = offer
       }),
       do: offer

  defp extract_ticket_offer_id(%Ticket{
         offer: %Offer{
           id: offer_id
         }
       }),
       do: offer_id
end
