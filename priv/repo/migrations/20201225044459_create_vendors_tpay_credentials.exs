defmodule Tipay.Repo.Migrations.CreateVendorsTpayCredentials do
  use Ecto.Migration

  def change do
    create table(:vendors_tpay_credentials) do
      add :vendor_id, references(:vendors, on_delete: :delete_all), null: false
      add :credentials_id, references(:tpay_credentials, on_delete: :delete_all), null: false
    end

    create unique_index(:vendors_tpay_credentials, [:vendor_id, :credentials_id])
  end
end
