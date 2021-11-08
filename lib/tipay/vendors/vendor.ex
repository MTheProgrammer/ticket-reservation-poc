defmodule Tipay.Vendors.Vendor do
  @moduledoc """
  Vendor struct
  """
  use Tipay.Schema
  import Ecto.Changeset

  schema "vendors" do
    field :name, :string
    field :description, :string
    field :address, :string
    field :opening_hours, :string
    field :active, :boolean

    timestamps()
  end

  @doc false
  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [:name, :description, :address, :opening_hours, :active])
    |> validate_required([:name, :description, :address, :opening_hours, :active])
    |> unique_constraint(:name, name: :vendors_name_index)
  end
end
