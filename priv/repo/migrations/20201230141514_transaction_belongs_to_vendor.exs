defmodule Tipay.Repo.Migrations.TransactionBelongsToVendor do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :vendor_id, references(:vendors), null: false
    end

    create index(:transactions, [:vendor_id])
  end
end
