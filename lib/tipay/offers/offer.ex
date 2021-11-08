defmodule Tipay.Offers.Offer do
  @moduledoc """
  Offer can be managed by users bound to Offer's parent Event
  """
  use Tipay.Schema
  import Ecto.Changeset
  import EctoEnum
  import Payment.Money
  import Ecto.DateValidator

  alias Ecto.Changeset
  alias Tipay.Offers.Offer

  defenum(Status, :offer_status, [:available, :sold_out])

  @doc """
  available_qty - total amount of offers
  sold_qty - sold and reserved offers. When all offers are sold, then sold_qty == available_qty

  published_at - offer preview visibility
  begins_at/ends_at - sale timeframe
  """
  schema "offers" do
    field :name, :string
    field :description, :string
    field :price, Money.Ecto.Composite.Type
    field :available_qty, :integer
    field :sold_qty, :integer, default: 0
    field :published_at, :utc_datetime_usec
    field :begins_at, :utc_datetime_usec
    field :ends_at, :utc_datetime_usec
    field :status, Status, virtual: true
    field :is_editable, :boolean, virtual: true
    belongs_to :event, Tipay.Events.Event
    has_one :vendor, through: [:event, :vendor]

    timestamps()
  end

  @doc false
  def changeset(offer, attrs) do
    offer
    |> cast(attrs, [
      :name,
      :description,
      :price,
      :available_qty,
      :sold_qty,
      :published_at,
      :begins_at,
      :ends_at,
      :event_id
    ])
    |> cast_assoc(:event)
    |> validate_money(:price)
    |> common_validators()
  end

  @doc false
  def create_changeset(offer, attrs) do
    offer
    |> changeset(attrs)
    |> validate_required([
      :name,
      :description,
      :price,
      :available_qty,
      :published_at,
      :begins_at,
      :ends_at,
      :event_id
    ])
    |> validate_money(:price)
    |> validate_dates
    |> common_validators()
  end

  def update_changeset(%Offer{sold_qty: sold_qty} = offer, attrs) when sold_qty > 0 do
    partial_update_changeset(offer, attrs)
    |> sold_qty_error_message("for offer with sold qty")
  end

  def update_changeset(%Offer{} = offer, attrs), do: full_update_changeset(offer, attrs)

  defp sold_qty_error_message(changeset, custom_error_message) do
    update_in(
      changeset.errors,
      &Enum.map(&1, fn
        {key, {error_message, rules}} ->
          {key, {error_message <> " " <> custom_error_message, rules}}
      end)
    )
  end

  @doc false
  defp full_update_changeset(offer, attrs) do
    offer
    |> changeset(attrs)
    |> validate_required([
      :name,
      :description,
      :available_qty,
      :ends_at
    ])
    |> validate_dates(:ends_at, other: :begins_at, cmp: :gt)
    |> common_validators()
  end

  @doc false
  defp partial_update_changeset(%Offer{sold_qty: sold_qty} = offer, attrs) do
    offer
    |> cast(attrs, [
      :name,
      :description,
      :available_qty,
      :ends_at
    ])
    |> validate_required([
      :name,
      :description,
      :available_qty,
      :ends_at
    ])
    |> validate_dates(:ends_at, other: :begins_at, comparision: :gt, original: true)
    |> validate_number(:available_qty, greater_than_or_equal_to: sold_qty)
    |> common_validators()
  end

  defp common_validators(changeset) do
    changeset
    |> validate_number(:available_qty, greater_than_or_equal_to: 0)
    |> validate_number(:sold_qty, greater_than_or_equal_to: 0)
  end

  @doc """
  Computes all virtual fields for the Offer
  """
  def put_virtual_fields(%Offer{} = offer) do
    offer
    |> Offer.compute_and_put_status()
    |> Offer.compute_and_put_is_editable()
  end

  def put_virtual_fields({:ok, %Offer{} = offer}) do
    {:ok, offer |> Offer.put_virtual_fields()}
  end

  def put_virtual_fields({result, changeset}), do: {result, changeset}

  @doc """
  Computes virtual field :status value and puts it for the Offer
  """
  def compute_and_put_status(%Offer{} = offer) do
    case Map.get(offer, :sold_qty) < Map.get(offer, :available_qty) do
      true -> Map.put(offer, :status, :available)
      _ -> Map.put(offer, :status, :sold_out)
    end
  end

  def compute_and_put_is_editable(%Offer{sold_qty: sold_qty} = offer)
      when not is_nil(sold_qty) and sold_qty > 0,
      do: Map.put(offer, :is_editable, false)

  def compute_and_put_is_editable(%Offer{} = offer),
    do: Map.put(offer, :is_editable, true)

  defp validate_dates(%Changeset{} = changeset) do
    changeset
    |> validate_dates(:published_at, other: :begins_at, cmp: :lt)
    |> validate_dates(:begins_at, other: :ends_at, cmp: :lt)
  end
end
