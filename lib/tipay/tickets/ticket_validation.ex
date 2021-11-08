defmodule Tipay.Tickets.TicketValidation do
  @moduledoc """
  Ticket Validation information struct.
  User is Usher who did validate the ticket.
  Only one validation can be performed for the ticket.
  """
  use Tipay.Schema
  import Ecto.Changeset

  schema "ticket_validations" do
    belongs_to :ticket, Tipay.Tickets.Ticket
    belongs_to :user, Tipay.Users.User
    field :used_token, :string

    timestamps()
  end

  @doc false
  def changeset(ticket_validation, attrs) do
    ticket_validation
    |> cast(attrs, [:user_id, :ticket_id, :used_token])
    |> validate_required([:user_id, :ticket_id, :used_token])
    |> foreign_key_constraint(:ticket_id, message: "Ticket does not exist")
    |> foreign_key_constraint(:user_id, message: "User does not exist")
    |> unique_constraint(:ticket_id, message: "Ticket was already validated")
  end
end
