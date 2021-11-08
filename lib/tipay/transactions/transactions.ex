defmodule Tipay.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Tipay.Offers
  alias Tipay.Offers.Offer
  alias Tipay.Repo
  alias Tipay.Transactions
  alias Tipay.Transactions.Transaction
  alias Tipay.Transactions.OfferBooking
  alias Tipay.Transactions.Events.EventBus

  defdelegate authorize(action, user, params), to: Tipay.Transactions.TransactionsPolicy

  def list_payments_mock do
    [
      %{
        id: 42,
        label: "mocked_payment",
        provider_code: :tpay
      }
    ]
  end

  @doc """
  Retrieve transaction
  """
  def get_transaction!(id) do
    Repo.get!(Transaction, id)
    |> Repo.preload([:offer_bookings])
  end

  @doc """
  Retrieve transaction by ID
  """
  def get_by_id(transaction_id) do
    case Repo.get_by(Transaction, id: transaction_id) do
      %Transaction{} = transaction ->
        transaction
        |> Repo.preload([:offer_bookings])

      _ ->
        nil
    end
  end

  @doc """
  Retrieve transaction by crc
  """
  def get_by_crc!(crc) when is_binary(crc) do
    case Repo.get_by(Transaction, id: crc) do
      %Transaction{} = transaction ->
        transaction
        |> Repo.preload([:offer_bookings])

      _ ->
        nil
    end
  end

  def get_by_crc!(_crc) do
    raise "invalid crc"
  end

  @doc """
  Retrieve user transactions with preloaded offer_bookings
  """
  def get_user_transactions(%{id: user_id}) do
    get_user_transactions(user_id)
  end

  def get_user_transactions(user_id) when not is_nil(user_id) do
    Transaction
    |> where([t], t.user_id == ^user_id)
    |> join(:left, [t], bookings in assoc(t, :offer_bookings))
    |> preload([t, bookings], offer_bookings: bookings)
    |> Repo.all()
  end

  @doc """
  Reserves offers. Reserves only available quantity, e.g. if user requested 3 qty for one offer, and only 2 are left, 2 are reserved.
  """
  def reserve(attrs \\ %{}) do
    changeset =
      %Transaction{}
      |> Transaction.changeset(attrs)

    # TODO: verify offer user
    # user_id = Changeset.get_change(changeset, :user_id)
    # with :ok <- Bodyguard.permit(Tipay.Transactions, :reserve, user_id, changeset),
    case changeset.valid? do
      true ->
        changeset
        |> process_changeset_offers
        |> persist_changes

      _ ->
        {:error, changeset}
    end
  end

  @doc """
  Cancels transaction and returns offers sold qty. Only transactions with specific status can be canceled.
  """
  def cancel_transaction(%Transaction{} = transaction) do
    cancel_changeset =
      transaction
      |> Repo.preload(:offer_bookings)
      |> Transaction.cancel_changeset()

    query_result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:transaction, cancel_changeset)
      |> Ecto.Multi.run(:decrement_sold_qty, &decrement_sold_qty/2)
      |> Repo.transaction()

    case query_result do
      {:ok, %{decrement_sold_qty: :ok, transaction: %Transaction{} = transaction}} ->
        reloaded_transaction = Transactions.get_transaction!(transaction.id)
        {:ok, reloaded_transaction}

      {:error, _, error, _errors} ->
        {:error, error}
    end
  end

  # TODO: one place for retrieving expiry period time - from the config - also set it in Transaction struct
  def cancel_outdated_transactions(expiry_period_seconds \\ 60, batch_size \\ 64) do
    # TODO: cursor based select
    query_expired_transactions(expiry_period_seconds)
    |> limit(^batch_size)
    |> Repo.all()
    |> Enum.map(&Transactions.cancel_transaction/1)

    # offset = process id * batch_size unless last one returns less items than batch_size
  end

  defp query_expired_transactions(expiry_period_seconds) do
    from t in Transaction,
      where: t.inserted_at <= ago(^expiry_period_seconds, "second"),
      where: t.status in [:new, :pending],
      order_by: t.inserted_at
  end

  @doc """
  Update transaction status e.g. after retrieved payment.
  Currently there is no logic that prevents going back in status order
  """
  def update_transaction_status(%Transaction{} = transaction, status) do
    result =
      transaction
      |> Transaction.update_status_changeset(%{status: status})
      |> Repo.update()

    case result do
      {:ok, _} ->
        EventBus.transaction_status_updated(transaction, status)
        result

      _ ->
        result
    end
  end

  defp persist_changes_transaction(changeset) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:transaction, changeset)
    |> Ecto.Multi.run(:increment_sold_qty, &increment_sold_qty/2)
    |> Ecto.Multi.run(:offer_qty_check, &maybe_rollback_on_zero_qty_offers/2)
    |> Repo.transaction()
  end

  defp maybe_rollback_on_zero_qty_offers(_repo, %{
         transaction: %{id: transaction_id}
       }) do
    case sum_transaction_real_offer_qty(transaction_id) == 0 do
      true -> {:error, "all offers were sold out"}
      false -> {:ok, :ok}
    end
  end

  defp sum_transaction_real_offer_qty(transaction_id) do
    Repo.one!(
      from ob in OfferBooking,
        where: [transaction_id: ^transaction_id],
        select: sum(ob.qty)
    )
  end

  defp persist_changes(changeset) do
    case persist_changes_transaction(changeset) do
      {:ok, %{increment_sold_qty: :ok, transaction: %Transaction{} = transaction}} ->
        reloaded_transaction = Transactions.get_transaction!(transaction.id)
        {:ok, reloaded_transaction}

      {:error, _, error, _errors} ->
        {:error, error}
    end
  end

  defp maybe_put_offer_booking_price(
         %Changeset{valid?: true, changes: %{offer_id: offer_id}} = changeset
       ) do
    case Offers.get_offer_by_id(offer_id) do
      %Offer{} = offer ->
        Changeset.put_change(changeset, :price, offer.price)

      _ ->
        Changeset.add_error(changeset, :offer_id, "offer does not exist")
    end
  end

  defp maybe_put_offer_booking_price(%Changeset{} = changeset) do
    changeset
  end

  defp maybe_put_offers_prices(
         %Changeset{valid?: true, changes: %{offer_bookings: offer_bookings}} = changeset
       ) do
    added_prices =
      offer_bookings
      |> Enum.map(&maybe_put_offer_booking_price/1)

    Changeset.put_change(changeset, :offer_bookings, added_prices)
  end

  defp maybe_put_offers_prices(%Changeset{} = changeset) do
    changeset
  end

  defp process_changeset_offers(%Changeset{} = changeset) do
    changeset
    |> maybe_put_offers_prices
  end

  defp increment_sold_qty(_repo, []) do
    {:ok, :ok}
  end

  defp increment_sold_qty(Repo = repo, [%{offer_id: offer_id, qty: qty} | tail]) do
    repo.update_all(increment_offer_sold_qty(offer_id, qty), [])

    increment_sold_qty(repo, tail)
  end

  defp increment_sold_qty(Repo = repo, %{transaction: transaction}) do
    increment_sold_qty(repo, transaction.offer_bookings)
  end

  defp decrement_sold_qty(_repo, []) do
    {:ok, :ok}
  end

  defp decrement_sold_qty(Repo = repo, [%{offer_id: offer_id, qty: qty} | tail]) do
    repo.update_all(increment_offer_sold_qty(offer_id, -qty), [])

    decrement_sold_qty(repo, tail)
  end

  defp decrement_sold_qty(Repo = repo, %{transaction: transaction}) do
    decrement_sold_qty(repo, transaction.offer_bookings)
  end

  defp increment_offer_sold_qty(offer_id, qty_to_increment) do
    from o in Offer,
      where: [id: ^offer_id],
      update: [
        inc: [
          sold_qty: ^qty_to_increment
        ]
      ]
  end
end
