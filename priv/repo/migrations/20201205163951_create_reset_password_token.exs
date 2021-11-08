defmodule Tipay.Repo.Migrations.CreateResetPasswordToken do
  use Ecto.Migration

  def change do
    create table(:reset_password_token) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :string, null: false

      timestamps()
    end

    create unique_index(:reset_password_token, [:user_id])
  end
end
