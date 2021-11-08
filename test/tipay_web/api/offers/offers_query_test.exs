defmodule TipayWeb.Api.OffersQueryTest do
  @moduledoc """
  Offers GraphQL query test
  """
  use TipayWeb.ApiCase, async: true

  setup do
    user = insert(:user)

    [user: user]
  end

  describe "offers query" do
    @all_public_offers_query """
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

    test "returns list of available public offers" do
      expected_offer =
        insert(:offer, name: "GQL Test Offer", ends_at: "3020-05-17T14:00:00.000000Z")

      insert(:sold_out_offer, ends_at: "3020-05-17T14:00:00.000000Z")
      insert(:unpublished_offer)

      expected_event_name = expected_offer.event.name

      assert %{
               "allPublicOffers" => [
                 %{
                   "id" => _,
                   "name" => "GQL Test Offer",
                   "status" => "AVAILABLE",
                   "description" => _,
                   "price" => %{"amount" => 4223, "currency" => "EUR"},
                   "publishedAt" => "2020-04-10T14:00:00.000000Z",
                   "endsAt" => "3020-05-17T14:00:00.000000Z",
                   "beginsAt" => "2020-04-17T14:00:00.000000Z",
                   "event" => %{
                     "name" => ^expected_event_name
                   }
                 },
                 %{
                   "id" => _,
                   "name" => _,
                   "status" => "SOLD_OUT",
                   "description" => _,
                   "price" => %{"amount" => 4223, "currency" => "EUR"},
                   "publishedAt" => "2020-04-10T14:00:00.000000Z",
                   "endsAt" => "3020-05-17T14:00:00.000000Z",
                   "beginsAt" => "2020-04-17T14:00:00.000000Z",
                   "event" => %{
                     "name" => _
                   }
                 }
               ]
             } = query(@all_public_offers_query, %{})
    end

    @all_public_offers_for_event_query """
    query($offerFilter: PublicOfferFilterInput!) {
      allPublicOffers(offerFilter: $offerFilter) {
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

    test "returns list of available public offers for a given event", %{user: user} do
      expected_offer = insert(:offer, name: "GQL Test Offer")
      insert(:offer)
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
                   "price" => %{"amount" => 4223, "currency" => "EUR"},
                   "publishedAt" => "2020-04-10T14:00:00.000000Z",
                   "endsAt" => _,
                   "beginsAt" => "2020-04-17T14:00:00.000000Z",
                   "event" => %{
                     "name" => ^expected_event_name
                   }
                 }
               ]
             } =
               query_with_user(@all_public_offers_for_event_query, user, %{
                 offerFilter: %{
                   event_id: expected_offer.event.id
                 }
               })
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
end
