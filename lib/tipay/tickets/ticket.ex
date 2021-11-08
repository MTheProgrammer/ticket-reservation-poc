defmodule Tipay.Tickets.Ticket do
  @moduledoc """
  Tickets struct
  """
  use Tipay.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(Status, :ticket_status, [:active, :validated])

  schema "tickets" do
    field :status, Status, default: :active
    belongs_to :user, Tipay.Users.User
    belongs_to :offer, Tipay.Offers.Offer
    has_one :ticket_validation, Tipay.Tickets.TicketValidation
    has_one :event, through: [:offer, :event]

    timestamps()
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:status, :user_id, :offer_id])
    |> validate_required([:user_id, :offer_id])
    |> foreign_key_constraint(:user_id, message: "User does not exist")
    |> foreign_key_constraint(:offer_id, message: "Offer does not exist")
  end

  @doc false
  def validate_ticket_changeset(ticket) do
    ticket
    |> change(%{status: :validated})
  end
end
