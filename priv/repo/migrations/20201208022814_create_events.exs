defmodule Tipay.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :short_description, :string
      add :description, :string
      add :published_at, :utc_datetime_usec, null: true
      add :begins_at, :utc_datetime_usec, null: true
      add :ends_at, :utc_datetime_usec, null: true
      add :active, :boolean, null: false, default: false

      timestamps()
    end
  end
end
