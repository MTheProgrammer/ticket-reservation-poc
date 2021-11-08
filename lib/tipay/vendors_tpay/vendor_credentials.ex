defmodule Tipay.VendorsTpay.VendorCredentials do
  @moduledoc """
  Bridge that binds TPay Credentials to Vendors
  """
  use Tipay.Schema
  import Ecto.Changeset

  schema "vendors_tpay_credentials" do
    belongs_to :vendor, Tipay.Vendors.Vendor
    belongs_to :credentials, Tipay.Tpay.Credentials
  end

  @doc false
  def changeset(vendor_tpay_credentials, attrs) do
    vendor_tpay_credentials
    |> cast(attrs, [:vendor_id, :credentials_id])
    |> validate_required([:vendor_id, :credentials_id])
    |> foreign_key_constraint(:vendor_id, message: "Vendor does not exist")
    |> foreign_key_constraint(:credentials_id, message: "Tpay Credentials does not exist")
    |> unique_constraint([:vendor_id, :credentials_id],
      message: "Tpay Credentials has been already asigned to this Vendor"
    )
  end
end
