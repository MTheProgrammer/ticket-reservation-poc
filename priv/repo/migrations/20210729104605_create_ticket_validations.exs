defmodule Tipay.Repo.Migrations.CreateTicketValidations do
  use Ecto.Migration

  def up do
    create table(:ticket_validations) do
      add :ticket_id, references(:tickets), null: false
      add :user_id, references(:users), null: false
      add :used_token, :string, null: false

      timestamps()
    end

    create unique_index(:ticket_validations, [:ticket_id])
  end

  def down do
    drop table(:tickets)
  end
end
