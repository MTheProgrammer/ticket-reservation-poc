defmodule Tipay.TransactionFactory do
  @moduledoc """
  ExMachina Transaction factory
  """
  defmacro __using__(_opts) do
    quote do
      def transaction_factory do
        vendor = insert(:vendor)
        [offer_a, offer_b] = insert_pair(:offer, vendor: vendor)

        %Tipay.Transactions.Transaction{
          accept_regulations: true,
          payment_method_id: 42,
          user: build(:user),
          vendor: vendor,
          offer_bookings: [
            %Tipay.Transactions.OfferBooking{
              qty: 5,
              offer: offer_a,
              price: offer_a.price
            },
            %Tipay.Transactions.OfferBooking{
              qty: 2,
              offer: offer_b,
              price: offer_b.price
            }
          ]
        }
      end

      def pending_transaction_factory do
        struct!(
          transaction_factory(),
          %{
            status: :pending
          }
        )
      end

      def paid_transaction_factory do
        struct!(
          transaction_factory(),
          %{
            status: :paid
          }
        )
      end
    end
  end
end
