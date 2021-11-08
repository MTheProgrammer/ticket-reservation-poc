defmodule Tipay.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  alias Tipay.Tickets.Ticket.Status

  def up do
    Status.create_type()

    create table(:tickets) do
      add :user_id, references(:users), null: false
      add :offer_id, references(:offers), null: false
      add :status, :ticket_status, null: false

      timestamps()
    end

    create index(:tickets, [:user_id])
    create index(:tickets, [:offer_id])
  end

  def down do
    drop table(:tickets)
    Status.drop_type()
  end
end
