defmodule Tipay.Transactions.OfferBooking do
  @moduledoc """
  Offer Booking defines an Offer and it's quantity to reserve
  """
  use Tipay.Schema
  import Ecto.Changeset
  import Payment.Money

  schema "offer_bookings" do
    field :qty, :integer, null: false
    field :price, Money.Ecto.Composite.Type, null: false
    belongs_to :transaction, Tipay.Events.Event
    belongs_to :offer, Tipay.Offers.Offer
  end

  @doc false
  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:qty, :price, :transaction_id, :offer_id])
    |> validate_required([:qty, :offer_id])
    |> validate_number(:qty, greater_than: 0)
    |> validate_money(:price)
  end
end
