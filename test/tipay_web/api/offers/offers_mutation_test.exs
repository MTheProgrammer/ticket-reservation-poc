defmodule TipayWeb.Api.OffersMutationTest do
  @moduledoc """
  Offers GraphQL mutation test
  """
  use TipayWeb.ApiCase, async: true

  describe "create an Offer mutation" do
    @create_offer_mutation """
    mutation($offer: OfferCreateInput!) {
      createOffer(offer: $offer) {
        success
        offer {
          id
          name
          description
          price {
            amount
            currency
          }
          publishedAt
          endsAt
          beginsAt
          status
          event {
            name
          }
          isEditable
        }
        errors
      }
    }
    """

    @valid_params %{
      name: "Super ticket",
      description: "Lorem Ipsum",
      price: %{amount: 12_345, currency: :eur},
      available_qty: 15,
      published_at: "2020-01-20T12:00:00Z",
      begins_at: "2020-01-25T12:00:00Z",
      ends_at: "2020-01-30T12:00:00Z"
    }

    test "creates a new Offer for logged in User who is bound to an Event" do
      event = insert(:event)
      user = event.user

      mutation_args = Map.put(@valid_params, :event_id, event.id)

      assert %{
               "createOffer" => %{
                 "errors" => nil,
                 "success" => true,
                 "offer" => %{
                   "id" => _,
                   "name" => "Super ticket"
                 }
               }
             } = mutate_with_user(@create_offer_mutation, user, offer: mutation_args)
    end

    test "reject creating a new Offer for logged in User who is not bound to an Event" do
      event = insert(:event)
      user = insert(:user)

      mutation_args = Map.put(@valid_params, :event_id, event.id)

      assert %{
               "createOffer" => %{
                 "errors" => %{message: "you are not allowed to create an offer for this event"},
                 "success" => false,
                 "offer" => nil
               }
             } = mutate_with_user(@create_offer_mutation, user, offer: mutation_args)
    end

    @not_existing_event_id "8277cd21-e2c5-4c4f-a647-a2b2ff753fd4"
    test "reject creating a new Offer for logged in User for not existing Event" do
      user = insert(:user)

      mutation_args = Map.put(@valid_params, :event_id, @not_existing_event_id)

      assert %{
               "createOffer" => %{
                 "errors" => %{message: "event does not exist"},
                 "success" => false,
                 "offer" => nil
               }
             } = mutate_with_user(@create_offer_mutation, user, offer: mutation_args)
    end
  end

  describe "edit an Offer mutation" do
    @edit_offer_mutation """
    mutation($offer: OfferEditInput!) {
      editMyOffer(offer: $offer) {
        success
        offer {
          id
          name
          description
          price {
            amount
            currency
          }
          availableQty
          soldQty
          publishedAt
          beginsAt
          endsAt
          isEditable
          event {
            id
          }
        }
        errors
      }
    }
    """

    test "edits whole existing, not sold yet Offer for logged in User who is bound to an Event" do
      offer = insert(:offer, sold_qty: 0)
      event = offer.event
      user = event.user
      other_event = insert(:event, user: user)

      mutation_args = %{
        id: offer.id,
        name: "New Name",
        description: "Other Description",
        price: %{amount: 77_777, currency: :eur},
        available_qty: 222,
        published_at: "3020-01-20T12:00:00Z",
        begins_at: "3020-01-25T12:00:00Z",
        ends_at: "3123-01-25T12:00:00Z",
        event_id: other_event.id
      }

      assert %{
               "editMyOffer" => %{
                 "errors" => nil,
                 "success" => true,
                 "offer" => %{
                   "id" => _,
                   "name" => "New Name",
                   "description" => "Other Description",
                   "price" => %{"amount" => 77_777, "currency" => "EUR"},
                   "availableQty" => 222,
                   "soldQty" => 0,
                   "publishedAt" => "3020-01-20T12:00:00.000000Z",
                   "beginsAt" => "3020-01-25T12:00:00.000000Z",
                   "endsAt" => "3123-01-25T12:00:00.000000Z"
                 }
               }
             } = mutate_with_user(@edit_offer_mutation, user, offer: mutation_args)
    end

    test "skips editing Offer non editable fields when offer has sold qty" do
      offer =
        insert(:offer,
          sold_qty: 1,
          published_at: ~U[2123-01-20T12:00:00Z],
          begins_at: ~U[2124-01-25T12:00:00Z],
          ends_at: ~U[2125-01-25T12:00:00Z]
        )

      event = offer.event
      user = event.user
      other_event = insert(:event, user: user)

      mutation_args = %{
        id: offer.id,
        name: "Super Offer 888",
        description: "Slipsum",
        price: %{"amount" => 77_777, "currency" => "EUR"},
        available_qty: 333,
        ends_at: "3325-01-25T12:00:00Z",
        event_id: other_event.id
      }

      assert %{
               "editMyOffer" => %{
                 "errors" => nil,
                 "success" => true,
                 "offer" => result_offer
               }
             } = mutate_with_user(@edit_offer_mutation, user, offer: mutation_args)

      assert %{
               "id" => "#{offer.id}",
               "name" => "Super Offer 888",
               "description" => "Slipsum",
               "availableQty" => 333,
               "soldQty" => offer.sold_qty,
               "price" => %{"amount" => 4223, "currency" => "EUR"},
               "publishedAt" => DateTime.to_iso8601(offer.published_at),
               "beginsAt" => DateTime.to_iso8601(offer.begins_at),
               "endsAt" => "3325-01-25T12:00:00.000000Z",
               "event" => %{"id" => "#{offer.event_id}"},
               "isEditable" => false
             } ==
               result_offer
    end

    test "prevent editing an existing Offer for logged in User who is not bound to an Event" do
      offer = insert(:offer)
      user = insert(:user)

      mutation_args = %{
        id: offer.id,
        name: "try to change me"
      }

      assert %{
               "editMyOffer" => %{
                 "errors" => %{message: "you are not allowed to modify an offer for this event"},
                 "success" => false,
                 "offer" => nil
               }
             } = mutate_with_user(@edit_offer_mutation, user, offer: mutation_args)
    end
  end

  describe "delete an Offer mutation" do
    @delete_offer_mutation """
    mutation($offerId: ID) {
      deleteMyOffer(offerId: $offerId) {
        success
        offer {
          id
        }
        errors
      }
    }
    """

    test "deletes an existing Offer for logged in User who is bound to an Event" do
      offer = insert(:offer, sold_qty: 0)
      event = offer.event
      user = event.user

      assert %{
               "deleteMyOffer" => %{
                 "errors" => nil,
                 "success" => true,
                 "offer" => %{
                   "id" => _
                 }
               }
             } = mutate_with_user(@delete_offer_mutation, user, offerId: offer.id)
    end

    test "prevent deleting existing Offer for logged in User who is not bound to an Event" do
      offer = insert(:offer)
      user = insert(:user)

      assert %{
               "deleteMyOffer" => %{
                 "errors" => %{message: "you are not allowed to modify an offer for this event"},
                 "success" => false,
                 "offer" => nil
               }
             } = mutate_with_user(@delete_offer_mutation, user, offerId: offer.id)
    end
  end
end
