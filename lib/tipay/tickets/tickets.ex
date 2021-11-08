defmodule Tipay.Tickets do
  import Ecto.Query, warn: false

  alias Tipay.Repo
  alias Ecto.Multi

  alias Tipay.Tickets
  alias Tipay.Tickets.Ticket
  alias Tipay.Tickets.TicketValidation
  alias Tipay.Users.User
  alias Tipay.UserTicketTokens.UserTicketToken
  alias Tipay.Offers.Offer

  defdelegate authorize(action, user, params), to: Tipay.Tickets.OwnerPolicy

  def get_ticket_by_id(id), do: Repo.get(Ticket, id)

  def get_user_ticket_list_by_ids(%UserTicketToken{user_id: user_id}, ids) when is_list(ids) do
    Ticket
    |> where([t], t.id in ^ids)
    |> where(user_id: ^user_id)
    |> preload(:offer)
    |> Repo.all()
  end

  def get_user_tickets_by_token(%UserTicketToken{user_id: user_id}) do
    Ticket
    |> where(user_id: ^user_id)
    |> preload(:offer)
    |> Repo.all()
  end

  def get_user_event_tickets_by_token(%UserTicketToken{user_id: user_id}, event_id)
      when is_binary(event_id) do
    Ticket
    |> where(user_id: ^user_id)
    |> join(:left, [t], o in Offer, on: o.event_id == ^event_id)
    |> preload(:offer)
    |> Repo.all()
  end

  def get_ticket_validation(%Ticket{id: ticket_id}),
    do: Repo.get_by(TicketValidation, ticket_id: ticket_id)

  @doc """
  Issues a new Offer's Ticket for an User.
  """
  def issue_new_ticket(%Offer{id: offer_id}, %User{id: user_id}) do
    issue_new_ticket(offer_id, user_id)
  end

  def issue_new_ticket(offer_id, user_id) when is_binary(offer_id) and is_binary(user_id) do
    %Ticket{}
    |> Ticket.changeset(%{offer_id: offer_id, user_id: user_id})
    |> Repo.insert()
  end

  @doc """
  Ticket Validation is a process where Usher is verifying the tickets provided by User.
  It is treated as single transaction - on any ticket validation failure e.g. when that ticket was already validated,
  the whole transaction is rolled back and process must be repeated with corrected tickets.
  """
  @spec validate_tickets(%Ticket{}, %User{}, %UserTicketToken{}) :: :ok | {:error, any()}
  def validate_tickets([%Ticket{}] = tickets, %User{} = usher, %UserTicketToken{} = token) do
    changesets =
      Enum.map(
        tickets,
        fn ticket ->
          %{
            ticket: Ticket.validate_ticket_changeset(ticket),
            ticket_validation: Tickets.ticket_to_ticket_validation_changeset(ticket, usher, token)
          }
        end
      )

    transaction_result =
      update_tickets_and_insert_validation(changesets)
      |> Repo.transaction()

    case transaction_result do
      {:ok, _} -> :ok
      error -> error
    end
  end

  defp update_tickets_and_insert_validation(changesets) do
    Enum.reduce(
      changesets,
      Multi.new(),
      fn %{ticket: ticket, ticket_validation: ticket_validation}, %Multi{} = multi ->
        multi
        |> Multi.insert(:ticket_validation, ticket_validation)
        |> Multi.update(:ticket, ticket)
      end
    )
  end

  @spec ticket_to_ticket_validation_changeset(%Ticket{}, %User{}, %UserTicketToken{}) ::
          %Ecto.Changeset{}
  def ticket_to_ticket_validation_changeset(
        %Ticket{id: ticket_id},
        %User{id: user_id},
        %UserTicketToken{id: token_id}
      ) do
    %TicketValidation{}
    |> TicketValidation.changeset(%{ticket_id: ticket_id, user_id: user_id, used_token: token_id})
  end
end
