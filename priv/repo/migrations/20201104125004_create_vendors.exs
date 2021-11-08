defmodule Tipay.Repo.Migrations.CreateVendors do
  use Ecto.Migration

  def change do
    create table(:vendors) do
      add :name, :string, null: false
      add :description, :string, null: true
      add :address, :string, null: true
      add :opening_hours, :string, null: true
      add :active, :boolean, null: true

      timestamps()
    end

    create index(:vendors, [:active], where: "active = true", name: :active_vendors)
    create unique_index(:vendors, [:name])
  end
end
