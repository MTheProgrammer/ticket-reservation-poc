defmodule TipayWeb.Api.OffersTest do
  @moduledoc """
  Offers GraphQL test
  """
  use TipayWeb.ApiCase, async: true

  @query """
  {
    allPublicOffers {
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
    }
  }
  """

  setup do
    user = insert(:user)

    [user: user]
  end

  describe "offers query" do
    test "returns list of available public offers", %{user: user} do
      expected_offer = insert(:offer, name: "GQL Test Offer")
      insert(:sold_out_offer)
      insert(:unpublished_offer)

      expected_event_name = expected_offer.event.name

      assert %{
               "allPublicOffers" => [
                 %{
                   "id" => _,
                   "name" => "GQL Test Offer",
                   "status" => "AVAILABLE",
                   "description" => _,
                   "price" => %{"amount" => 42_23, "currency" => "EUR"},
                   "publishedAt" => "2020-04-10T14:00:00.000000Z",
                   "endsAt" => _,
                   "beginsAt" => _,
                   "event" => %{
                     "name" => ^expected_event_name
                   }
                 },
                 %{
                   "id" => _,
                   "name" => _,
                   "status" => "SOLD_OUT",
                   "description" => _,
                   "price" => %{"amount" => 42_23, "currency" => "EUR"},
                   "publishedAt" => "2020-04-10T14:00:00.000000Z",
                   "endsAt" => _,
                   "beginsAt" => _,
                   "event" => %{
                     "name" => _
                   }
                 }
               ]
             } = query_with_user(@query, user, %{})
    end
  end

  describe "my offers query" do
    @my_offers_query """
    query($offerFilter: OfferFilterInput!) {
      myOffers(offerFilter: $offerFilter) {
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
    }
    """

    test "returns list of user's filtered offers" do
      event = insert(:event)
      user = event.user

      expected_offer =
        insert(:offer,
          name: "Expected Offer",
          event: event,
          published_at: "2020-04-11T14:00:00.000000Z"
        )

      insert(:sold_out_offer,
        name: "Another Expected Offer",
        event: event,
        published_at: "2020-04-10T14:00:00.000000Z"
      )

      insert(:unpublished_offer)
      insert(:offer)

      assert %{
               "myOffers" => [
                 %{
                   "description" => _,
                   "id" => _,
                   "name" => "Another Expected Offer",
                   "price" => %{"amount" => 4223, "currency" => "EUR"},
                   "publishedAt" => "2020-04-10T14:00:00.000000Z",
                   "endsAt" => _,
                   "beginsAt" => "2020-04-17T14:00:00.000000Z",
                   "status" => "SOLD_OUT",
                   "event" => %{
                     "name" => _
                   }
                 },
                 %{
                   "description" => _,
                   "id" => _,
                   "name" => "Expected Offer",
                   "price" => %{"amount" => 4223, "currency" => "EUR"},
                   "publishedAt" => "2020-04-11T14:00:00.000000Z",
                   "endsAt" => _,
                   "beginsAt" => "2020-04-17T14:00:00.000000Z",
                   "status" => "AVAILABLE",
                   "event" => %{
                     "name" => _
                   }
                 }
               ]
             } =
               query_with_user(@my_offers_query, user, %{
                 offerFilter: %{
                   event_id: expected_offer.event.id
                 }
               })
    end

    test "returns error when requested offer that does not belong to user" do
      event = insert(:event)
      user = insert(:user)
      insert(:offer, event: event)
      insert(:sold_out_offer, event: event)
      insert(:unpublished_offer)
      insert(:offer)

      assert {:error, [%{message: "you are not allowed to create an offer for this event"}]} =
               query_with_user(@my_offers_query, user, %{
                 offerFilter: %{
                   event_id: event.id
                 }
               })
    end
  end

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
      price: %{amount: 1234, currency: :eur},
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
        price: %{amount: 77_777, currency: :eur},
        available_qty: 333,
        ends_at: "2333-01-25T12:00:00Z",
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
               "endsAt" => "2333-01-25T12:00:00.000000Z",
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
