defmodule Tipay.Repo.Migrations.CreateUserTicketTokens do
  use Ecto.Migration

  alias Tipay.UserTicketTokens.UserTicketToken.Status

  def up do
    Status.create_type()

    create table(:user_ticket_tokens) do
      add :user_id, references(:users), null: false
      add :status, :user_ticket_token_status, null: false
      add :name, :string, null: false

      timestamps()
    end

    create index(:user_ticket_tokens, [:user_id])
  end

  def down do
    drop table(:user_ticket_tokens)
    Status.drop_type()
  end
end
