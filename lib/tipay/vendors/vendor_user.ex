defmodule Tipay.Vendors.VendorUser do
  @moduledoc """
  Binds Users to Vendors
  """
  use Tipay.Schema
  import Ecto.Changeset

  schema "vendors_users" do
    belongs_to :vendor, Tipay.Vendors.Vendor
    belongs_to :user, Tipay.Users.User
  end

  @doc false
  def changeset(vendor_user, attrs) do
    vendor_user
    |> cast(attrs, [:vendor_id, :user_id])
    |> validate_required([:vendor_id, :user_id])
    |> foreign_key_constraint(:vendor_id, message: "Vendor does not exist")
    |> foreign_key_constraint(:user_id, message: "User does not exist")
    |> unique_constraint([:vendor_id, :user_id],
      message: "User has been already assigned to this Vendor"
    )
  end
end
