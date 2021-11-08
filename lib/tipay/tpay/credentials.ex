defmodule Tipay.Tpay.Credentials do
  @moduledoc """
  TPay Credentials struct
  """
  use Tipay.Schema
  import Ecto.Changeset

  schema "tpay_credentials" do
    field :api_key, :string, null: false
    # TODO: this should not be stored as plain text in db
    field :api_password, :string, null: false
    field :merchant_id, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [:api_key, :api_password, :merchant_id])
    |> validate_required([:api_key, :api_password, :merchant_id])
  end
end
