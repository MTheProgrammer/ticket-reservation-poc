defmodule TipayWeb.Api.Resolvers.TicketsResolver do
  @moduledoc """
  Tickets GraphQL Resolver
  """
  alias Tipay.Users
  alias Tipay.Users.User
  alias Tipay.Tickets
  alias Tipay.Tickets.Ticket
  alias Tipay.UserTicketTokens
  alias Tipay.UserTicketTokens.UserTicketToken
  alias Tipay.UserTicketTokens.Helpers.TicketGroup

  def validate_tickets(
        _root,
        %{user_token: user_token, ticket_ids: ticket_ids},
        %{context: %{current_user: %User{} = usher}}
      ) do
    user_ticket_token = UserTicketTokens.get_user_ticket_token_by_id(user_token)

    case user_ticket_token do
      %UserTicketToken{} = token -> validate_user_tickets(token, usher, ticket_ids)
      _ -> get_invalid_user_token_error()
    end
  end

  defp validate_user_tickets(%UserTicketToken{} = user_ticket_token, %User{} = usher, ticket_ids)
       when is_list(ticket_ids) do
    tickets = Tickets.get_user_ticket_list_by_ids(user_ticket_token, ticket_ids)

    case length(tickets) > 0 do
      true -> try_validate_tickets(tickets, usher, user_ticket_token)
      false -> get_not_existing_ticket_ids_error(ticket_ids, tickets)
    end
  end

  defp get_invalid_user_token_error do
    {:error, %{"message" => "invalid user token"}}
  end

  defp get_not_existing_ticket_ids_error(ticket_ids, tickets) do
    existing_ids = Enum.map(tickets, fn %{id: id} -> id end)
    invalid_ids = ticket_ids -- existing_ids

    {
      :error,
      %{
        "message" => "invalid ticket(s)",
        "ticketIds" => invalid_ids
      }
    }
  end

  defp check_event_tickets_for_usher(tickets, usher) do
    not_usher_events = get_not_usher_events(tickets, usher)

    case length(not_usher_events) > 0 do
      true ->
        {
          :error,
          %{
            "message" => "you can't validate these ticket(s)",
            "ticketIds" => not_usher_events
          }
        }

      false ->
        :ok
    end
  end

  defp get_not_usher_events(tickets, usher) do
    Enum.reduce(tickets, [], fn %Ticket{id: ticket_id, offer: %{event_id: event_id}}, result ->
      case can_usher_validate_event_tickets(usher, event_id) do
        true -> result
        false -> [ticket_id | result]
      end
    end)
  end

  defp try_validate_tickets(tickets, usher, user_ticket_token) do
    with :ok <- check_event_tickets_for_usher(tickets, usher),
         :ok <- Tickets.validate_tickets(tickets, usher, user_ticket_token) do
      {:ok, %{success: true}}
    else
      error ->
        handle_ticket_validation_errors(error)
    end
  end

  defp handle_ticket_validation_errors(error) do
    case error do
      {
        :error,
        :ticket_validation,
        %Ecto.Changeset{changes: %{ticket_id: ticket_id}} = error_changeset,
        _
      } ->
        {:error, %{changeset: error_changeset, id: ticket_id}}

      {:error, _, %Ecto.Changeset{} = error_changeset, _} ->
        {:error, error_changeset}

      error ->
        error
    end
  end

  defp can_usher_validate_event_tickets(%User{} = usher, event_id) when is_binary(event_id) do
    case Bodyguard.permit(Tickets, :validate_event_tickets, usher, event_id) do
      :ok -> true
      _ -> false
    end
  end

  def user_event_tickets(
        _root,
        %{event_id: event_id, user_token: user_token},
        %{
          context: %{
            current_user: %User{} = usher
          }
        }
      ) do
    case can_usher_view_event_tickets(usher, event_id) do
      true -> maybe_return_user_tickets(user_token, event_id)
      false -> {:error, :unauthorized}
    end
  end

  defp maybe_return_user_tickets(user_token, event_id)
       when is_binary(user_token) and is_binary(event_id) do
    case UserTicketTokens.get_user_ticket_token_by_id(user_token) do
      %UserTicketToken{} = user_ticket_token ->
        get_user_event_tickets(user_ticket_token, event_id)

      _ ->
        {:error, :user_not_found}
    end
  end

  defp maybe_return_user_tickets(_, _), do: raise("invalid event_id or user_token")

  defp can_usher_view_event_tickets(%User{} = usher, event_id) when is_binary(event_id) do
    case Bodyguard.permit(Tickets, :view_event_tickets, usher, event_id) do
      :ok -> true
      _ -> false
    end
  end

  defp get_user_event_tickets(%UserTicketToken{user_id: user_id} = user_ticket_token, event_id)
       when is_binary(event_id) do
    user_event_tickets = Tickets.get_user_event_tickets_by_token(user_ticket_token, event_id)

    offer_tickets =
      user_event_tickets
      |> TicketGroup.group_tickets_by_offer()
      |> format_offer_tickets

    result = %{
      user: Users.get_user_by_id(user_id),
      offers: offer_tickets
    }

    {:ok, result}
  end

  defp format_offer_tickets(offer_tickets) do
    Enum.map(
      offer_tickets,
      fn entry = %{tickets: tickets} ->
        formatted_tickets = format_tickets(tickets)
        Map.put(entry, :tickets, formatted_tickets)
      end
    )
  end

  defp format_tickets(tickets) do
    Enum.map(
      tickets,
      fn ticket = %{inserted_at: inserted_at} ->
        Map.put_new(ticket, :buy_date, inserted_at)
      end
    )
  end
end
