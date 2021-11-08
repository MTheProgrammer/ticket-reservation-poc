defmodule Tipay.Repo.Migrations.CreateTpayCredentials do
  use Ecto.Migration

  def change do
    create table(:tpay_credentials) do
      add :api_key, :string, null: false
      add :api_password, :string, null: false
      add :merchant_id, :string, null: false

      timestamps()
    end
  end
end
