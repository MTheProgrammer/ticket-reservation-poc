defmodule TipayWeb.Api.TransactionsQueryTest do
  @moduledoc """
  Transactions GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "all payments query" do
    @all_payments """
    {
      allPayments {
        provider_code
        ... on TpayPayment {
          id
          label
        }
      }
    }
    """

    test "returns list of available Payments" do
      user = insert(:user)

      assert %{
               "allPayments" => [
                 %{
                   "id" => "42",
                   "label" => "mocked_payment",
                   "provider_code" => "tpay"
                 }
               ]
             } = query_with_user(@all_payments, user, %{})
    end
  end

  setup do
    user = insert(:user)

    [
      user: user,
      other_user: insert(:user),
      transaction: insert(:transaction, user: user)
    ]
  end

  describe "user transactions query" do
    @get_my_transaction """
    query ($transactionId: ID!) {
      getMyTransaction(transactionId: $transactionId) {
        id
        paymentMethodId
        status
        offerBookings {
          id
          qty
          offer {
            id
            name
          }
        }
      }
    }
    """

    test "query getMyTransaction returns user's transaction", %{
      user: user,
      transaction: %{id: transaction_id} = transaction
    } do
      %{
        :offer_bookings => [
          %{
            :qty => offer_booking_qty,
            :offer => %{
              :name => offer_name
            }
          }
          | _tail
        ]
      } = transaction

      assert %{
               "getMyTransaction" => %{
                 "id" => _,
                 "status" => "NEW",
                 "paymentMethodId" => "42",
                 "offerBookings" => [
                   %{
                     "id" => _,
                     "qty" => ^offer_booking_qty,
                     "offer" => %{
                       "id" => _,
                       "name" => ^offer_name
                     }
                   }
                   | _tail
                 ]
               }
             } = query_with_user(@get_my_transaction, user, %{transaction_id: transaction_id})
    end

    test "query getMyTransaction returns unauthorized for invalid user", %{
      other_user: other_user,
      transaction: %{id: transaction_id}
    } do
      assert {:error, [%{message: "unauthorized", path: ["getMyTransaction"]}]} =
               query_with_user(@get_my_transaction, other_user, %{transaction_id: transaction_id})
    end

    @my_transactions """
    {
      myTransactions {
        id
        paymentMethodId
        status
        offerBookings {
          id
          qty
          offer {
            id
            name
          }
        }
      }
    }
    """

    test "query myTransactions returns user's transactions", %{
      user: user,
      transaction: transaction
    } do
      %{
        :offer_bookings => [
          %{
            :qty => offer_booking_qty,
            :offer => %{
              :name => offer_name
            }
          }
          | _tail
        ]
      } = transaction

      assert %{
               "myTransactions" => [
                 %{
                   "id" => _,
                   "status" => "NEW",
                   "paymentMethodId" => "42",
                   "offerBookings" => [
                     %{
                       "id" => _,
                       "qty" => ^offer_booking_qty,
                       "offer" => %{
                         "id" => _,
                         "name" => ^offer_name
                       }
                     }
                     | _tail
                   ]
                 }
               ]
             } = query_with_user(@my_transactions, user, %{})
    end
  end
end
