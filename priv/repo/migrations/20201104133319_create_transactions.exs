defmodule Tipay.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    Tipay.Transactions.Transaction.Status.create_type()

    create table(:transactions) do
      add :accept_regulations, :boolean, null: false
      add :payment_method_id, :id, null: false
      add :status, :transaction_status, null: false

      timestamps()
    end
  end
end
