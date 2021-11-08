defmodule TipayWeb.Api.EventsQueryTest do
  @moduledoc """
  Events GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  alias Tipay.Events.Event

  defp normalize_date_field(%{} = struct, field_name) do
    normalized_date =
      struct
      |> Map.get(field_name)
      |> DateTime.to_iso8601()

    struct
    |> Map.put(field_name, normalized_date)
  end

  defp normalize_event_dates(%Event{} = event) do
    event
    |> normalize_date_field(:published_at)
    |> normalize_date_field(:begins_at)
    |> normalize_date_field(:ends_at)
  end

  defp whitelist_graphql_fields(%Event{} = event) do
    event
    |> normalize_event_dates()
    |> Map.take([
      :id,
      :name,
      :short_description,
      :description,
      :published_at,
      :begins_at,
      :ends_at,
      :active
    ])
  end

  defp whitelist_graphql_fields(events) do
    events
    |> Enum.map(&whitelist_graphql_fields/1)
  end

  describe "my events query" do
    @my_events_query """
    query($availability: EventAvailability, $vendorId: ID) {
      myEvents(availability: $availability, vendorId: $vendorId) {
        id
        name
        short_description
        description
        published_at
        begins_at
        ends_at
        active
      }
    }
    """

    setup do
      [
        users: insert_pair(:user),
        days: %{
          yesterday: build(:utc_yesterday),
          tomorrow: build(:utc_tomorrow),
          next_week: build(:utc_next_week)
        }
      ]
    end

    test "returns list of Users's Events", %{
      users: [user, other_user]
    } do
      insert_list(2, :event, user: other_user)

      expected_event = insert(:event, user: user)

      insert_list(2, :event, user: other_user)

      assert %{
               "myEvents" => [result_event]
             } = query_with_user(@my_events_query, user, %{})

      assert expected_event
             |> whitelist_graphql_fields() ==
               result_event
               |> keys_to_atoms()
    end

    test "returns list of Users's pending Events", %{
      users: [user, other_user],
      days: %{yesterday: yesterday, tomorrow: tomorrow}
    } do
      insert_list(2, :event, user: other_user)

      _users_finished_events = insert_list(2, :event, user: user, ends_at: yesterday)

      expected_pending_event = insert(:event, user: user, ends_at: tomorrow)

      assert %{
               "myEvents" => [result_event]
             } = query_with_user(@my_events_query, user, %{availability: :pending})

      assert expected_pending_event
             |> whitelist_graphql_fields() ==
               result_event
               |> keys_to_atoms()
    end

    test "returns list of Users's finished Events", %{
      users: [user, other_user],
      days: %{yesterday: yesterday, tomorrow: tomorrow}
    } do
      insert_list(2, :event, user: other_user)

      _users_pending_events = insert_list(2, :event, user: user, ends_at: tomorrow)

      expected_finished_event = insert(:event, user: user, ends_at: yesterday)

      assert %{
               "myEvents" => [result_event]
             } = query_with_user(@my_events_query, user, %{availability: :finished})

      assert expected_finished_event
             |> whitelist_graphql_fields() ==
               result_event
               |> keys_to_atoms()
    end

    test "returns list of Users's Events for a given Vendor ID", %{
      users: [user, _other_user]
    } do
      %{id: expected_event_id, vendor_id: vendor_id} = insert(:event, user: user)
      insert(:event, user: user)

      assert %{
               "myEvents" => [
                 %{
                   "id" => ^expected_event_id
                 }
               ]
             } = query_with_user(@my_events_query, user, %{vendor_id: vendor_id})
    end

    @get_my_event_query """
    query ($eventId: ID!) {
      getMyEvent(eventId: $eventId) {
        event {
          id
          name
          short_description
          description
          published_at
          begins_at
          ends_at
          active
          offers {
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
        success
        errors
      }
    }
    """

    test "returns Event that can be edited by current User" do
      event = insert(:event)
      offer = insert(:offer, event: event)
      user = event.user

      assert %{
               "getMyEvent" => %{
                 "success" => true,
                 "event" => %{
                   "id" => result_event_id,
                   "offers" => [
                     %{"id" => result_offer_id}
                   ]
                 },
                 "errors" => nil
               }
             } = query_with_user(@get_my_event_query, user, %{event_id: event.id})

      expected_event_id = event.id
      assert ^expected_event_id = result_event_id

      expected_offer_id = offer.id
      assert ^expected_offer_id = result_offer_id
    end

    test "returns error for Event that can't be edited by current User" do
      user = insert(:user)
      invalid_event_id = "8277cd21-e2c5-4c4f-a647-a2b2ff753fd4"

      assert {:error, [%{message: "not_found", path: ["getMyEvent"]}]} =
               query_with_user(@get_my_event_query, user, %{event_id: invalid_event_id})
    end

    test "returns error for Event that does not belong to current User" do
      event = insert(:event)
      user = insert(:user)

      assert {:error, [%{message: "unauthorized", path: ["getMyEvent"]}]} =
               query_with_user(@get_my_event_query, user, %{event_id: event.id})
    end
  end

  describe "public events query" do
    @published_events_list_query """
    query ($vendorId: ID) {
      publishedEvents(vendorId: $vendorId) {
        id
        name
        published_at
        begins_at
        ends_at
        active
        __typename
        ... on PublicActiveEvent {
          short_description
          description
          vendor_id
        }
      }
    }
    """

    setup do
      [
        days: %{
          yesterday: build(:utc_yesterday),
          tomorrow: build(:utc_tomorrow),
          next_week: build(:utc_next_week)
        }
      ]
    end

    test "returns published list of Events. Inactive events are returned with limited details", %{
      days: %{yesterday: yesterday, tomorrow: tomorrow, next_week: next_week}
    } do
      _future_event = insert(:event, published_at: tomorrow)
      _future_active_event = insert(:event, published_at: tomorrow, active: true)

      published_event =
        insert(:event, published_at: yesterday, active: true, begins_at: tomorrow)
        |> normalize_event_dates()

      published_inactive_event =
        insert(:event, published_at: yesterday, active: false, begins_at: next_week)
        |> normalize_event_dates()

      assert %{
               "publishedEvents" => query_result
             } = query(@published_events_list_query, %{})

      [result_event_active, result_event_inactive] = keys_to_atoms(query_result)

      assert published_event.name == result_event_active.name
      assert published_event.short_description == result_event_active.short_description
      assert published_event.description == result_event_active.description
      assert published_event.published_at == result_event_active.published_at
      assert published_event.begins_at == result_event_active.begins_at
      assert published_event.ends_at == result_event_active.ends_at
      assert published_event.active == result_event_active.active
      assert "#{published_event.vendor_id}" == result_event_active.vendor_id

      assert published_inactive_event.name == result_event_inactive.name
      assert published_inactive_event.published_at == result_event_inactive.published_at
      assert published_inactive_event.begins_at == result_event_inactive.begins_at
      assert published_inactive_event.ends_at == result_event_inactive.ends_at
      assert published_inactive_event.active == result_event_inactive.active
    end

    test "returns published list of Events for a given vendor", %{
      days: %{yesterday: yesterday, tomorrow: tomorrow}
    } do
      %{id: expected_event_id, vendor_id: vendor_id} =
        insert(:event, published_at: yesterday, active: true, begins_at: tomorrow)
        |> normalize_event_dates()

      _other_vendor_event =
        insert(:event, published_at: yesterday, active: true, begins_at: tomorrow)
        |> normalize_event_dates()

      assert %{
               "publishedEvents" => [
                 %{
                   "id" => ^expected_event_id
                 }
               ]
             } = query(@published_events_list_query, %{vendor_id: vendor_id})
    end

    @get_public_event_query """
    query($eventId: ID!) {
      getPublicEvent(eventId: $eventId) {
        id
        name
        published_at
        begins_at
        ends_at
        active
        __typename
        ... on PublicActiveEvent {
          short_description
          description
          vendor_id
        }
      }
    }
    """

    test "returns publicly available event by id" do
      future_event = insert(:event, published_at: "3333-01-01T12:00:00Z")
      future_active_event = insert(:event, published_at: "3333-01-01T12:00:00Z", active: true)

      published_event =
        insert(:event,
          published_at: "2012-01-01T12:00:00Z",
          active: true,
          begins_at: "3333-01-01T12:00:00Z"
        )
        |> normalize_event_dates()

      published_inactive_event =
        insert(:event,
          published_at: "2012-01-01T12:00:00Z",
          active: false,
          begins_at: "3333-01-01T12:00:00Z"
        )
        |> normalize_event_dates()

      assert %{
               "getPublicEvent" => %{
                 "name" => _
               }
             } = query(@get_public_event_query, %{event_id: published_event.id})

      assert %{
               "getPublicEvent" => %{
                 "name" => _
               }
             } =
               query(@get_public_event_query, %{
                 event_id: published_inactive_event.id
               })

      assert %{"getPublicEvent" => nil} =
               query(@get_public_event_query, %{event_id: future_event.id})

      assert %{"getPublicEvent" => nil} =
               query(@get_public_event_query, %{event_id: future_active_event.id})
    end
  end
end
