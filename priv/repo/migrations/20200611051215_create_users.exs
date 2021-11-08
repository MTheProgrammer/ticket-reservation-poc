defmodule Tipay.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    create table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :citext, null: false
      add :password_hash, :string
      add :nick, :string, null: false
      add :has_accepted_terms, :boolean, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:nick])
  end
end
