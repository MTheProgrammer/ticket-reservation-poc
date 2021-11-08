defmodule Tipay.Transactions.Status do
  @moduledoc """
  Transaction Status struct
  """
  use Tipay.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(TransactionStatus, :transaction_status, [:pending, :paid, :fraud, :canceled])

  schema "transaction_statuses" do
    field :status, TransactionStatus, null: false, default: :pending
    belongs_to :transaction, Tipay.Transactions.Transaction

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:status, :transaction_id])
    |> validate_required([:status, :transaction_id])
  end
end
