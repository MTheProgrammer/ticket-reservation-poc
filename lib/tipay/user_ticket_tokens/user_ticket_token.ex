defmodule Tipay.UserTicketTokens.UserTicketToken do
  @moduledoc """
  Tickets assigned to users
  """
  use Tipay.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(Status, :user_ticket_token_status, [:active, :inactive])

  schema "user_ticket_tokens" do
    field :name, :string
    field :status, Status, default: :active
    belongs_to :user, Tipay.Users.User

    timestamps()
  end

  @doc false
  def changeset(user_ticket_token, attrs) do
    user_ticket_token
    |> cast(attrs, [:name, :status, :user_id])
    |> validate_required([:name, :status, :user_id])
    |> foreign_key_constraint(:user_id, message: "User does not exist")
  end
end
