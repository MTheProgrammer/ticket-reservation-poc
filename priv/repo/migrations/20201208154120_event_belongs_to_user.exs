defmodule Tipay.Repo.Migrations.EventBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :user_id, references(:users), null: false
    end

    create index(:events, [:user_id])
  end
end
