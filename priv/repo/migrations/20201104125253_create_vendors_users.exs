defmodule Tipay.Repo.Migrations.CreateVendorsUsers do
  use Ecto.Migration

  def change do
    create table(:vendors_users) do
      add :vendor_id, references(:vendors, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:vendors_users, [:vendor_id, :user_id])
  end
end
