defmodule Tipay.Repo.Migrations.TransactionBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :user_id, references(:users), null: false
    end

    create index(:transactions, [:user_id])
  end
end
