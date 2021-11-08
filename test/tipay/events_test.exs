defmodule Tipay.EventsTest do
  @moduledoc """
  Events Repo test
  """
  use Tipay.DataCase, async: true

  import Assertions

  alias Tipay.Events
  alias Tipay.Events.Event

  defp drop_refs(%{} = entity) do
    Map.drop(entity, [:vendor, :user])
  end

  describe "events management" do
    setup do
      [event: insert(:event)]
    end

    test "list_events/0 returns all events", %{event: event} do
      [result_event] = Events.list_events()

      assert drop_refs(event) == drop_refs(result_event)
    end

    test "get_event!/1 returns the event with given id", %{event: event} do
      result_event = Events.get_event!(event.id)

      assert drop_refs(event) == drop_refs(result_event)
    end

    test "delete_event/1 deletes the event", %{event: event} do
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset", %{event: event} do
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end

  describe "event types resolvers" do
    test "get_public_event/1 returns public event with given id and returns nil for unpublished ones" do
      event =
        insert(:event,
          active: true,
          published_at: "2012-12-21T12:00:00Z",
          begins_at: "2013-12-21T12:00:00Z",
          ends_at: "3333-01-01T12:00:00Z"
        )

      inactive_event =
        insert(:event,
          active: false,
          published_at: "2012-12-21T12:00:00Z",
          begins_at: "2013-12-21T12:00:00Z",
          ends_at: "3333-01-01T12:00:00Z"
        )

      unpublished_event = insert(:event, active: true, published_at: "3012-12-21T12:00:00Z")

      %Event{} = Events.get_public_event(event.id)
      %Event{} = Events.get_public_event(inactive_event.id)
      nil = Events.get_public_event(unpublished_event.id)
    end

    test "create_event/1 with valid data creates an event" do
      event_desc = insert(:event)

      event_attrs = %{
        name: event_desc.name,
        short_description: event_desc.short_description,
        description: event_desc.description,
        published_at: event_desc.published_at,
        begins_at: event_desc.begins_at,
        ends_at: event_desc.ends_at,
        active: event_desc.active,
        vendor_id: event_desc.vendor.id,
        user_id: event_desc.user.id
      }

      assert {:ok, %Event{} = event} = Events.create_event(event_attrs)

      assert_maps_equal(event, event_desc, [
        :name,
        :short_description,
        :description,
        :published_at,
        :begins_at,
        :ends_at,
        :active,
        :vendor_id,
        :user_id
      ])
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, changeset} =
               Events.create_event(%{
                 name: nil,
                 short_description: nil,
                 description: nil,
                 published_at: nil,
                 begins_at: nil,
                 ends_at: nil,
                 active: nil,
                 vendor_id: nil,
                 user_id: nil
               })

      assert %{
               active: ["can't be blank"],
               begins_at: ["can't be blank"],
               description: ["can't be blank"],
               ends_at: ["can't be blank"],
               name: ["can't be blank"],
               published_at: ["can't be blank"],
               short_description: ["can't be blank"],
               vendor_id: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "create_event/1 for inctive event returns error" do
      inactive_vendor = insert(:vendor, active: false)
      event_desc = insert(:event, vendor: inactive_vendor)

      event_attrs = %{
        name: event_desc.name,
        short_description: event_desc.short_description,
        description: event_desc.description,
        published_at: event_desc.published_at,
        begins_at: event_desc.begins_at,
        ends_at: event_desc.ends_at,
        active: event_desc.active,
        vendor_id: event_desc.vendor.id,
        user_id: event_desc.user.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Events.create_event(event_attrs)

      assert %{
               vendor_id: ["event's vendor must be active"]
             } = errors_on(changeset)
    end

    test "update_event/2 with valid data updates the event" do
      event = insert(:event)
      event_desc = build(:event)

      assert {:ok, %Event{} = event} =
               Events.update_event(event, %{
                 name: event_desc.name,
                 short_description: event_desc.short_description,
                 description: event_desc.description,
                 published_at: event_desc.published_at,
                 begins_at: event_desc.begins_at,
                 ends_at: event_desc.ends_at,
                 active: event_desc.active
               })

      assert_maps_equal(event, event_desc, [
        :name,
        :short_description,
        :description,
        :published_at,
        :begins_at,
        :ends_at,
        :active
      ])
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = insert(:event)

      assert {:error, %Ecto.Changeset{}} =
               Events.update_event(event, %{
                 name: nil,
                 short_description: nil,
                 description: nil,
                 published_at: nil,
                 begins_at: nil,
                 ends_at: nil,
                 active: nil
               })

      result = Events.get_event!(event.id)

      assert drop_refs(result) == drop_refs(event)
    end
  end

  describe "events listing" do
    alias Tipay.Events.Event

    setup do
      published_past_event =
        build(:event)
        |> published
        |> past
        |> insert

      published_future_event =
        build(:event)
        |> published
        |> future
        |> active
        |> insert

      pending_event =
        build(:event)
        |> published
        |> pending
        |> active
        |> insert

      [
        past_events: [published_past_event],
        future_events: [published_future_event],
        pending_events: [pending_event, published_future_event]
      ]
    end

    test "list_pending_events/0 returns events that have not yet started", %{
      pending_events: pending_events
    } do
      result = Events.list_pending_events()

      assert_ids_match(pending_events, result)
    end

    test "list_completed_events/0 returns events that are finished", %{
      past_events: past_events
    } do
      result = Events.list_completed_events()

      assert_ids_match(past_events, result)
    end
  end

  describe "published events" do
    setup do
      published_past_event =
        build(:event)
        |> published
        |> past
        |> insert

      [
        published_events: [published_past_event]
      ]
    end

    test "list_published_events/0 returns events that are publicly available", %{
      published_events: published_events
    } do
      result = Events.list_published_events()

      assert_ids_match(published_events, result)
    end
  end

  defp assert_ids_match(left, right) when is_list(left) and is_list(right) do
    assert_lists_equal(left, right, &assert_ids_match/2)
  end

  defp assert_ids_match(%{id: id}, %{id: id}), do: true
  defp assert_ids_match(_, _), do: false
end
