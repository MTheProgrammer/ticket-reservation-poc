defmodule Tipay.Events.Event do
  @moduledoc """
  Events struct
  """
  use Tipay.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :short_description, :string
    field :description, :string
    field :published_at, :utc_datetime_usec
    field :begins_at, :utc_datetime_usec
    field :ends_at, :utc_datetime_usec
    field :active, :boolean, default: false
    belongs_to :vendor, Tipay.Vendors.Vendor
    belongs_to :user, Tipay.Users.User
    has_many :offers, Tipay.Offers.Offer

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :short_description,
      :description,
      :published_at,
      :begins_at,
      :ends_at,
      :active,
      :vendor_id,
      :user_id
    ])
    |> validate_required([
      :name,
      :short_description,
      :description,
      :published_at,
      :begins_at,
      :ends_at,
      :active,
      :vendor_id,
      :user_id
    ])
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :short_description,
      :description,
      :published_at,
      :begins_at,
      :ends_at,
      :active
    ])
    |> validate_required([
      :name,
      :short_description,
      :description,
      :published_at,
      :begins_at,
      :ends_at,
      :active
    ])
  end
end
