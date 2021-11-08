defmodule Tipay.Transactions.Transaction do
  @moduledoc """
  Transaction struct. It holds a reference to the Bookings, which then are as whole converted to Reservation.
  """
  use Tipay.Schema
  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset
  alias Tipay.Transactions.OfferBooking
  alias Tipay.Offers
  alias Tipay.Transactions.Transaction

  defenum(Status, :transaction_status, [:new, :pending, :paid, :canceled])

  schema "transactions" do
    # TODO: accepted regulations should be defined
    # as related field with apropriate regulations version - to comply with GDPR requirements
    field(:accept_regulations, :boolean)
    field(:payment_method_id, :id)
    field(:status, Status, default: :new)
    belongs_to(:user, Tipay.Users.User)
    belongs_to(:vendor, Tipay.Vendors.Vendor)
    has_many(:offer_bookings, Tipay.Transactions.OfferBooking)
    has_many(:offers, through: [:offer_bookings, :offer])

    field(:total_qty, :integer, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:accept_regulations, :payment_method_id, :user_id])
    |> cast_assoc(:offer_bookings, with: &OfferBooking.changeset/2)
    |> validate_length(:offer_bookings, min: 1)
    |> validate_required([:accept_regulations, :payment_method_id])
    |> foreign_key_constraint(:user_id, message: "user is required")
    |> try_put_vendor()
    |> Ecto.Changeset.put_change(:status, :pending)
    |> foreign_key_constraint(:vendor_id, message: "vendor is required")
    |> check_offers()
  end

  defp get_offers(%Changeset{} = changeset) do
    get_offers_ids(changeset)
    |> Offers.get_offers_by_ids()
  end

  defp get_offers_ids(%Changeset{} = changeset) do
    changeset
    |> Changeset.get_change(:offer_bookings)
    |> Enum.map(&Changeset.get_change(&1, :offer_id))
    |> Enum.uniq()
  end

  defp check_offers(%Changeset{} = changeset) do
    offers = get_offers(changeset)

    changeset
    |> maybe_add_not_existing_offers_error(offers)
    |> check_offers_sale_availability(offers)
    |> offers_belong_to_one_vendor(offers)
  end

  defp check_offers_sale_availability(%Changeset{} = changeset, offers) do
    {:ok, now_datetime} = DateTime.now("Etc/UTC")

    is_valid_offers_timeframe =
      Enum.reduce_while(offers, :ok, fn %Tipay.Offers.Offer{} = offer, _acc ->
        case check_offer_sale_timeframe(offer, now_datetime) do
          :ok -> {:cont, :ok}
          {:error, error} -> {:halt, error}
        end
      end)

    case is_valid_offers_timeframe do
      :ok ->
        changeset

      error ->
        Changeset.add_error(changeset, :offer_bookings, error)
    end
  end

  defp check_offer_sale_timeframe(%{} = offer, now_datetime) do
    with :ok <- check_offer_begins_at(offer, now_datetime),
         :ok <- check_offer_ends_at(offer, now_datetime) do
      :ok
    else
      error -> error
    end
  end

  defp check_offer_begins_at(%{begins_at: begins_at}, now_datetime) do
    case Date.compare(begins_at, now_datetime) do
      :gt -> {:error, "offer sale has not yet started"}
      _ -> :ok
    end
  end

  defp check_offer_ends_at(%{ends_at: ends_at}, now_datetime) do
    case Date.compare(ends_at, now_datetime) do
      :lt -> {:error, "offer sale has ended"}
      _ -> :ok
    end
  end

  defp maybe_add_not_existing_offers_error(%Changeset{} = changeset, offers) do
    offers_ids = get_offers_ids(changeset)

    case length(offers) !== length(offers_ids) do
      true ->
        changeset
        |> Changeset.add_error(:offer_bookings, "invalid offers ids")

      _ ->
        changeset
    end
  end

  defp offers_belong_to_one_vendor(changeset, offers) do
    unique_vendors_count =
      offers
      |> get_offers_unique_vendors_ids()
      |> Enum.count()

    maybe_add_non_unique_offers_vendor_error(changeset, unique_vendors_count)
  end

  defp maybe_add_non_unique_offers_vendor_error(changeset, unique_vendors_count)
       when unique_vendors_count > 1 do
    changeset
    |> Changeset.add_error(:offer_bookings, "offers must belong to one vendor")
  end

  defp maybe_add_non_unique_offers_vendor_error(changeset, _) do
    changeset
  end

  defp get_offers_unique_vendors_ids(offers) do
    offers
    |> Tipay.Repo.preload([:vendor])
    |> Enum.map(fn %{vendor: %{id: vendor_id}} -> vendor_id end)
    |> Enum.uniq()
  end

  def cancel_changeset(transaction) do
    transaction
    |> change(%{
      status: :canceled
    })
    |> can_be_canceled(transaction)
  end

  def update_status_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  defp can_be_canceled(changeset, %Transaction{status: status}) do
    case status do
      :pending ->
        changeset

      _ ->
        add_error(changeset, :status, "transaction can't be canceled")
    end
  end

  defp try_put_vendor(changeset) do
    with %Ecto.Changeset{valid?: true, changes: %{offer_id: offer_id}} <-
           changeset
           |> Ecto.Changeset.get_change(:offer_bookings)
           |> List.first(),
         %Tipay.Offers.Offer{} = offer <-
           Tipay.Offers.get_offer_by_id(offer_id) do
      %{id: vendor_id} =
        offer
        |> Tipay.Repo.preload(:vendor)
        |> Map.get(:vendor)

      changeset
      |> Ecto.Changeset.put_change(:vendor_id, vendor_id)
    else
      _ -> changeset
    end
  end

  def to_payment_info(%Transaction{} = transaction) do
    %{
      amount: sum_amount(transaction),
      booking_to: get_booking_to(transaction)
    }
  end

  def get_currency(%Transaction{offer_bookings: [%OfferBooking{} = offer_booking | _tail]}) do
    %Money{currency: currency} = offer_booking.price

    currency
  end

  def sum_amount(%Transaction{offer_bookings: offer_bookings}) do
    sum_amount(offer_bookings)
  end

  def sum_amount([%OfferBooking{} | _tail] = offer_bookings) when is_list(offer_bookings) do
    offer_bookings
    |> Enum.reduce(nil, fn %{qty: qty, price: price}, sum ->
      offer_booking_cost = Money.multiply(price, qty)

      case sum do
        nil -> offer_booking_cost
        _ -> Money.add(sum, offer_booking_cost)
      end
    end)
  end

  def sum_amount(_) do
    Money.new(0)
  end

  def get_booking_to(%Transaction{inserted_at: inserted_at}) do
    expiry_time = Application.get_env(:tipay, :transaction_expiry_seconds)

    inserted_at
    |> DateTime.add(expiry_time, :second)
  end
end
