defmodule TipayWeb.Api.TransactionsMutationTest do
  @moduledoc """
  Transactions GraphQL test case
  """
  use TipayWeb.ApiCase, async: false

  import Tesla.Mock

  @base_url "https://api.tpay.com"

  defmacrop url(path) do
    @base_url <> path
  end

  @create_transaction_mutation """
  mutation($transaction: TransactionCreateInput!) {
    createTransaction(transaction: $transaction) {
      success
      transactionPayment {
        amount {
          amount
          currency
        }
        bookingTo
        url
        transaction {
          id
          status
          offerBookings {
            qty
          }
        }
      }
      errors
    }
  }
  """

  defp oauth_mock(%{method: :post, url: url("/oauth/auth")}) do
    json(%{
      "issued_at" => 1_526_995_718,
      "scope" => "read write",
      "expires_in" => 7200,
      "token_type" => "Bearer",
      "client_id" => "testclient",
      "access_token" => "1b19469129b2c22459f3d4cd71275fca4b2f94da"
    })
  end

  defp success_transaction_mock(%{method: :post, url: url("/transactions")}) do
    json(%{
      "result" => "success",
      "requestId" => "85136c79cbf9fe36bb9",
      "transactionId" => "ta_6UvbBjehvHXA7vfD",
      "title" => "TR-BRA-KGZK0X",
      "posId" => "ps_6UvbBjehvHXA7vfD",
      "date" => %{
        "creation" => "2019-06-28 15:35:40",
        "realization" => nil
      },
      "amount" => 200.15,
      "currency" => "PLN",
      "description" => "Transakcja testowa",
      "hiddenDescription" => "123456",
      "payer" => %{
        "email" => "jan.kowalski@example.com",
        "name" => "Jan Kowalski"
      },
      "transactionPaymentUrl" => "https://secure.tpay.com/transactions/11771/pay"
    })
  end

  defp failed_transaction_mock(%{method: :post, url: url("/transactions")}) do
    json(
      %{
        result: false,
        requestId: "7Q6bO29dwBZ1Mm0RvX2p30GkaAlJoVN4Lnz3Wgqr",
        errors: [
          %{
            errorCode: "invalid_pos_id",
            errorMessage:
              "Provided point of sales ID is in an incorrect format (must be a string of numbers and letters with prefix ps_ )",
            devMessage: "Provided POS id does not satisfy regexp /ps_[a-zA-Z0-9]{16}/",
            docUrl: "https://support.tpay.com/en/case-study/implementing-payment-gateway"
          }
        ]
      },
      status: 400
    )
  end

  describe "create a Transaction mutation" do
    setup do
      mock(fn %{url: url} = request ->
        case url do
          url("/oauth/auth") -> oauth_mock(request)
          url("/transactions") -> success_transaction_mock(request)
        end
      end)

      :ok
    end

    test "creates a new Transaction for logged in user" do
      user = insert(:user)
      vendors_credentials = insert(:vendors_tpay_vendor_credentials)
      vendor = vendors_credentials.vendor
      event = insert(:event, vendor: vendor)
      [offer_a, offer_b] = insert_pair(:offer, event: event)

      mutation_args = %{
        accept_regulations: true,
        # TODO: payment methods resolver
        payment_method_id: 42,
        offer_bookings: [
          %{
            offer_id: offer_a.id,
            qty: 5
          },
          %{
            offer_id: offer_b.id,
            qty: 3
          }
        ]
      }

      assert %{
               "createTransaction" => %{
                 "errors" => nil,
                 "success" => true,
                 "transactionPayment" => %{
                   "amount" => %{"amount" => 20015, "currency" => "USD"},
                   "bookingTo" => _,
                   "url" => "https://secure.tpay.com/transactions/11771/pay",
                   "transaction" => %{
                     "id" => _,
                     "status" => "PENDING",
                     "offerBookings" => _
                   }
                 }
               }
             } = mutate_with_user(@create_transaction_mutation, user, transaction: mutation_args)
    end
  end

  describe "create a Transaction mutation returns error" do
    setup do
      mock(fn %{url: url} = request ->
        case url do
          url("/oauth/auth") -> oauth_mock(request)
          url("/transactions") -> failed_transaction_mock(request)
        end
      end)

      :ok
    end

    test "on API error createTransaction returns nice message for customer" do
      user = insert(:user)
      vendors_credentials = insert(:vendors_tpay_vendor_credentials)
      vendor = vendors_credentials.vendor
      event = insert(:event, vendor: vendor)
      [offer_a, offer_b] = insert_pair(:offer, event: event)

      mutation_args = %{
        accept_regulations: true,
        payment_method_id: 42,
        offer_bookings: [
          %{
            offer_id: offer_a.id,
            qty: 5
          },
          %{
            offer_id: offer_b.id,
            qty: 3
          }
        ]
      }

      assert %{
               "createTransaction" => %{
                 "errors" => %{
                   msg: [
                     %{
                       "devMessage" =>
                         "Provided POS id does not satisfy regexp /ps_[a-zA-Z0-9]{16}/",
                       "docUrl" =>
                         "https://support.tpay.com/en/case-study/implementing-payment-gateway",
                       "errorCode" => "invalid_pos_id",
                       "errorMessage" =>
                         "Provided point of sales ID is in an incorrect format (must be a string of numbers and letters with prefix ps_ )"
                     }
                   ]
                 },
                 "success" => false,
                 "transactionPayment" => nil
               }
             } = mutate_with_user(@create_transaction_mutation, user, transaction: mutation_args)
    end
  end
end
