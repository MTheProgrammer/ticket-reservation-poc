defmodule Tipay.Repo.Migrations.OfferBelongsToEvent do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :event_id, references(:events), null: false
    end

    create index(:offers, [:event_id])
  end
end
