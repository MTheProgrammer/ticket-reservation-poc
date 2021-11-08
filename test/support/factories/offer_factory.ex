defmodule Tipay.OfferFactory do
  @moduledoc """
  ExMachina Offer factory
  """
  defmacro __using__(_opts) do
    quote do
      def offer_factory do
        %Tipay.Offers.Offer{
          name: sequence(:offer_name, &"offer #{&1}"),
          description: sequence(:offer_description, &"Lorem ipsum #{&1}"),
          price: Money.new(42_23, :EUR),
          available_qty: 42,
          sold_qty: 2,
          published_at: ~U[2020-04-10 14:00:00.000000Z],
          begins_at: ~U[2020-04-17 14:00:00.000000Z],
          ends_at: ~U[4020-05-17 14:00:00.000000Z],
          event: build(:event)
        }
      end

      def sold_out_offer_factory do
        struct!(
          offer_factory(),
          %{
            name: sequence(:sold_out_offer_name, &"sold out offer #{&1}"),
            available_qty: 10,
            sold_qty: 10
          }
        )
      end

      def unpublished_offer_factory do
        struct!(
          offer_factory(),
          %{
            name: sequence(:sold_out_offer_name, &"unpublished offer #{&1}"),
            available_qty: 10,
            sold_qty: 0,
            published_at: future_date_factory(10),
            begins_at: future_date_factory(11),
            ends_at: future_date_factory(12)
          }
        )
      end
    end
  end
end
