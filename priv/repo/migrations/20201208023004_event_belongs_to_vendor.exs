defmodule Tipay.Repo.Migrations.EventBelongsToVendor do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :vendor_id, references(:vendors), null: false
    end

    create index(:events, [:vendor_id])
  end
end
