defmodule Tipay.TransactionsTest do
  @moduledoc """
  Transactions Context test
  """
  use Tipay.DataCase, async: true

  alias Tipay.Offers
  alias Tipay.Offers.Offer
  alias Tipay.Transactions
  alias Tipay.Transactions.OfferBooking

  describe "transactions positive paths" do
    alias Tipay.Transactions.Transaction

    test "reserve/1 with valid data creates a transaction" do
      insert(:user)
      offer = insert(:offer)

      offer_booking_desc = %{
        qty: 2,
        offer_id: offer.id
      }

      template = insert(:transaction)

      transaction_desc = %{
        accept_regulations: template.accept_regulations,
        payment_method_id: template.payment_method_id,
        user_id: template.user.id,
        offer_bookings: [offer_booking_desc]
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.reserve(transaction_desc)

      assert transaction.accept_regulations == template.accept_regulations
      assert transaction.payment_method_id == template.payment_method_id
      assert transaction.user_id == template.user.id

      assert [%OfferBooking{} = result_offer_booking] = transaction.offer_bookings
      assert result_offer_booking.offer_id == offer.id
      assert result_offer_booking.transaction_id == transaction.id
      assert result_offer_booking.qty == 2
    end

    test "reserve/1 reserves offer with qty equal to remaining available quantity for reservation" do
      insert(:user)
      offer = insert(:offer, available_qty: 10, sold_qty: 8)

      offer_booking_desc = %{
        qty: 2,
        offer_id: offer.id
      }

      template = insert(:transaction)

      transaction_desc = %{
        accept_regulations: template.accept_regulations,
        payment_method_id: template.payment_method_id,
        user_id: template.user.id,
        offer_bookings: [offer_booking_desc]
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.reserve(transaction_desc)

      assert transaction.accept_regulations == template.accept_regulations
      assert transaction.payment_method_id == template.payment_method_id
      assert transaction.user_id == template.user.id

      affected_offer = Offers.get_offer_by_id(offer.id)
      assert %Offer{:sold_qty => 10, :available_qty => 10} = affected_offer

      assert [%OfferBooking{} = result_offer_booking] = transaction.offer_bookings
      assert result_offer_booking.offer_id == offer.id
      assert result_offer_booking.transaction_id == transaction.id
      assert result_offer_booking.qty == 2
    end

    test "reserve/1 with booking qty > offer available_qty overflow creating transaction for only remaining qty" do
      insert(:user)
      offer = insert(:offer, available_qty: 10, sold_qty: 8)

      offer_booking_desc = %{
        qty: 3,
        offer_id: offer.id
      }

      template = insert(:transaction)

      transaction_desc = %{
        accept_regulations: template.accept_regulations,
        payment_method_id: template.payment_method_id,
        user_id: template.user.id,
        offer_bookings: [offer_booking_desc]
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.reserve(transaction_desc)

      assert transaction.accept_regulations == template.accept_regulations
      assert transaction.payment_method_id == template.payment_method_id
      assert transaction.user_id == template.user.id

      affected_offer = Offers.get_offer_by_id(offer.id)
      assert %Offer{:sold_qty => 10, :available_qty => 10} = affected_offer

      assert [%OfferBooking{} = result_offer_booking] = transaction.offer_bookings
      assert result_offer_booking.offer_id == offer.id
      assert result_offer_booking.transaction_id == transaction.id
      assert result_offer_booking.qty == 2
    end

    test "reserve/1 for already sold offer reserves 0 if other offers are available" do
      insert(:user)
      event = insert(:event)
      offer = insert(:offer, available_qty: 10, sold_qty: 10, event: event)
      available_offer = insert(:offer, available_qty: 10, sold_qty: 2, event: event)

      offer_bookings = [
        %{
          qty: 3,
          offer_id: offer.id
        },
        %{
          qty: 2,
          offer_id: available_offer.id
        }
      ]

      template = insert(:transaction)

      transaction_desc = %{
        accept_regulations: template.accept_regulations,
        payment_method_id: template.payment_method_id,
        user_id: template.user.id,
        offer_bookings: offer_bookings
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.reserve(transaction_desc)

      assert [%OfferBooking{} = result_offer_booking | [result_available_offer_booking | _tail]] =
               transaction.offer_bookings

      assert result_offer_booking.offer_id == offer.id
      assert result_offer_booking.qty == 0

      assert %Offer{} = result_offer = Offers.get_offer_by_id(offer.id)
      assert result_offer.available_qty == 10
      assert result_offer.sold_qty == 10

      assert result_available_offer_booking.offer_id == available_offer.id
      assert result_available_offer_booking.qty == 2

      assert %Offer{} = available_result_offer = Offers.get_offer_by_id(available_offer.id)
      assert available_result_offer.available_qty == 10
      assert available_result_offer.sold_qty == 4
    end
  end

  describe "transactions negative paths" do
    alias Tipay.Transactions.Transaction

    test "reserve/1 with invalid data returns Error Changeset" do
      insert(:user)

      transaction_desc = %{
        accept_regulations: nil,
        payment_method_id: nil,
        user_id: nil,
        offer_bookings: []
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Transactions.reserve(transaction_desc)

      assert %{
               accept_regulations: ["can't be blank"],
               payment_method_id: ["can't be blank"],
               offer_bookings: ["should have at least 1 item(s)"]
             } = errors_on(error_changeset)
    end

    test "reserve/1 with empty user returns Error Changeset" do
      offer = insert(:offer)

      transaction_desc = %{
        accept_regulations: true,
        payment_method_id: 42,
        user_id: "8277cd21-e2c5-4c4f-a647-a2b2ff753fd4",
        offer_bookings: [%{offer_id: offer.id, qty: 1}]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Transactions.reserve(transaction_desc)

      assert %{
               user_id: ["user is required"]
             } = errors_on(error_changeset)
    end

    test "reserve/1 with Offers having Events of different Vendors returns Error Changeset" do
      user = insert(:user)

      offers =
        insert_pair(:vendor)
        |> Enum.map(fn vendor -> insert(:event, vendor: vendor) end)
        |> Enum.map(fn event -> insert(:offer, event: event) end)

      transaction_desc = %{
        accept_regulations: true,
        payment_method_id: 42,
        user_id: user.id,
        offer_bookings:
          Enum.map(offers, fn %{id: offer_id} ->
            %{offer_id: offer_id, qty: 1}
          end)
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Transactions.reserve(transaction_desc)

      assert %{
               offer_bookings: ["offers must belong to one vendor"]
             } = errors_on(error_changeset)
    end

    test "reserve/1 with not existing offers returns Error Changeset" do
      user = insert(:user)

      transaction_desc = %{
        accept_regulations: true,
        payment_method_id: 42,
        user_id: user.id,
        offer_bookings: [
          %{offer_id: "8277cd21-e2c5-4c4f-a647-a2b2ff753fd4", qty: 1},
          %{offer_id: "8277cd21-e2c5-4c4f-a647-a2b2ff753fd5", qty: 1},
          %{offer_id: "8277cd21-e2c5-4c4f-a647-a2b2ff753fd6", qty: 1}
        ]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Transactions.reserve(transaction_desc)

      assert %{
               offer_bookings: ["invalid offers ids"]
             } = errors_on(error_changeset)
    end

    test "reserve/1 with offers without available quantity returns Error" do
      user = insert(:user)
      offer = insert(:offer, available_qty: 10, sold_qty: 10)

      transaction_desc = %{
        accept_regulations: true,
        payment_method_id: 42,
        user_id: user.id,
        offer_bookings: [
          %{offer_id: offer.id, qty: 5}
        ]
      }

      assert {:error, "all offers were sold out"} = Transactions.reserve(transaction_desc)
    end

    test "reserve/1 offers before sale start, returns Error" do
      user = insert(:user)

      offer =
        insert(:offer, available_qty: 10, sold_qty: 0, begins_at: ~U[4020-04-10 00:00:00.000000Z])

      transaction_desc = %{
        accept_regulations: true,
        payment_method_id: 42,
        user_id: user.id,
        offer_bookings: [
          %{offer_id: offer.id, qty: 1}
        ]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Transactions.reserve(transaction_desc)

      assert %{
               offer_bookings: ["offer sale has not yet started"]
             } = errors_on(error_changeset)
    end

    test "reserve/1 offers after sale end, returns Error" do
      user = insert(:user)

      offer =
        insert(:offer, available_qty: 10, sold_qty: 0, ends_at: ~U[2020-04-10 00:00:00.000000Z])

      transaction_desc = %{
        accept_regulations: true,
        payment_method_id: 42,
        user_id: user.id,
        offer_bookings: [
          %{offer_id: offer.id, qty: 1}
        ]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Transactions.reserve(transaction_desc)

      assert %{
               offer_bookings: ["offer sale has ended"]
             } = errors_on(error_changeset)
    end
  end

  describe "transactions cancel positive paths" do
    alias Offers.Offer
    alias Tipay.Transactions
    alias Tipay.Transactions.Transaction

    test "cancel/1 with reserved transaction cancels transaction" do
      insert(:user)
      offer = insert(:offer, available_qty: 10, sold_qty: 5)

      offer_booking_desc = %{
        qty: 2,
        offer_id: offer.id,
        price: offer.price
      }

      offer_bookings = [offer_booking_desc]

      transaction = insert(:pending_transaction, offer_bookings: offer_bookings)

      assert {:ok, %Transaction{} = canceled_transaction} =
               Transactions.cancel_transaction(transaction)

      assert canceled_transaction.status == :canceled

      returned_offer = Tipay.Repo.get(Offer, offer.id)
      assert returned_offer.sold_qty == 3
    end

    test "cancel_outdated_transactions/2 cancels expired transactions" do
      expected_note_expired = insert(:transaction, status: :pending)

      expected_canceled_transaction =
        insert(:transaction, status: :pending, inserted_at: "1999-01-01 00:00:00Z")

      Transactions.cancel_outdated_transactions()

      assert %Transaction{status: :pending} = Repo.get(Transaction, expected_note_expired.id)

      assert %Transaction{status: :canceled} =
               Repo.get(Transaction, expected_canceled_transaction.id)
    end
  end

  describe "transactions cancel negative paths" do
    alias Offers.Offer
    alias Tipay.Transactions.Transaction

    for status <- [:new, :paid, :canceled] do
      @test_status status
      test "cancel/1 rejects transaction in status #{status}" do
        insert(:user)
        offer = insert(:offer, available_qty: 10, sold_qty: 5)

        offer_booking_desc = %{
          qty: 2,
          offer_id: offer.id,
          price: offer.price
        }

        offer_bookings = [offer_booking_desc]

        transaction = insert(:transaction, offer_bookings: offer_bookings, status: @test_status)

        assert {:error, %Ecto.Changeset{} = error_changeset} =
                 Transactions.cancel_transaction(transaction)

        assert %{
                 status: ["transaction can't be canceled"]
               } = errors_on(error_changeset)

        returned_offer = Tipay.Repo.get(Offer, offer.id)
        assert returned_offer.sold_qty == 5
      end
    end
  end

  describe "transactions queries" do
    alias Tipay.Transactions
    alias Tipay.Transactions.Transaction

    test "get_user_transactions/1 is preloading related offer bookings" do
      _not_expected_transaction = insert(:transaction)

      user = insert(:user)

      expected_transaction = insert(:transaction, user: user)
      [%{id: booking_a_id}, %{id: booking_b_id}] = expected_transaction.offer_bookings

      assert [%Transaction{} = result_transaction] = Transactions.get_user_transactions(user.id)

      assert result_transaction.id == expected_transaction.id

      assert [
               %{:id => ^booking_a_id},
               %{:id => ^booking_b_id}
             ] = result_transaction.offer_bookings
    end

    test "get_user_transactions/1 returns same results for User struct and for user_id argument" do
      user = insert(:user)
      insert(:transaction, user: user)

      assert Transactions.get_user_transactions(user.id) ==
               Transactions.get_user_transactions(user)
    end
  end
end
