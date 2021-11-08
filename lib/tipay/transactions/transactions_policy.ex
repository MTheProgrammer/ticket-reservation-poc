defmodule Tipay.Transactions.TransactionsPolicy do
  @moduledoc """
  User owner policy for the Transactions
  """
  @behaviour Bodyguard.Policy

  alias Tipay.Transactions.Transaction
  alias Tipay.Users.User

  def authorize(:list_transactions, _, _), do: true

  def authorize(:view, %User{id: user_id}, %Transaction{user_id: user_id}), do: true

  def authorize(:reserve, %User{id: user_id}, %Ecto.Changeset{} = changeset) do
    authorize(:reserve, user_id, changeset)
  end

  def authorize(:reserve, user_id, %Ecto.Changeset{valid?: true} = changeset) do
    get_offers_ids(changeset)
    |> Tipay.Offers.is_any_owned_by?(user_id)
  end

  def authorize(_, _, _), do: false

  defp get_offers_ids(changeset) do
    Ecto.Changeset.get_change(changeset, :offer_bookings)
    |> Enum.map(fn changeset -> Ecto.Changeset.get_change(changeset, :offer_id) end)
  end
end
