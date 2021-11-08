defmodule TipayWeb.Api.EventsMutationTest do
  @moduledoc """
  Events GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "create an Event mutation" do
    @create_event_mutation """
    mutation($event: EventCreateInput!) {
      createEvent(event: $event) {
        success
        event {
          name
          short_description
          description
          published_at
          begins_at
          ends_at
          active
        }
        errors
      }
    }
    """

    test "creates a new Event for logged in user" do
      user = insert(:user)
      vendor = insert(:vendor)

      mutation_args = %{
        name: "Budka Suflera - pożegnanie",
        short_description: "Lorem Ipsum Short",
        description: "Lorem Ipsum Long",
        published_at: "3020-01-20T12:00:00Z",
        begins_at: "3020-01-25T20:00:00Z",
        ends_at: "3020-01-25T23:00:00Z",
        active: false,
        vendor_id: vendor.id
      }

      assert %{
               "createEvent" => %{
                 "errors" => nil,
                 "success" => true,
                 "event" => %{
                   "name" => "Budka Suflera - pożegnanie",
                   "short_description" => "Lorem Ipsum Short",
                   "description" => "Lorem Ipsum Long",
                   "published_at" => "3020-01-20T12:00:00.000000Z",
                   "begins_at" => "3020-01-25T20:00:00.000000Z",
                   "ends_at" => "3020-01-25T23:00:00.000000Z",
                   "active" => false
                 }
               }
             } = mutate_with_user(@create_event_mutation, user, event: mutation_args)
    end
  end

  describe "edit an Event mutation" do
    @edit_my_event_mutation """
    mutation($event: EventEditInput!) {
      editMyEvent(event: $event) {
        success
        event {
          name
          short_description
          description
          published_at
          begins_at
          ends_at
          active
        }
        errors
      }
    }
    """

    @valid_params %{
      name: "Eric Clapton",
      short_description: "Slipsum",
      description: "Tasty burger",
      published_at: "2021-01-20T12:00:00Z",
      begins_at: "2021-01-25T20:00:00Z",
      ends_at: "2021-01-25T23:00:00Z",
      active: true
    }

    test "edits an existing Event for logged in user" do
      existing_event = insert(:event)
      user = existing_event.user

      mutation_args =
        @valid_params
        |> Map.merge(%{id: existing_event.id})

      assert %{
               "editMyEvent" => %{
                 "errors" => nil,
                 "success" => true,
                 "event" => %{
                   "name" => "Eric Clapton",
                   "short_description" => "Slipsum",
                   "description" => "Tasty burger",
                   "published_at" => "2021-01-20T12:00:00.000000Z",
                   "begins_at" => "2021-01-25T20:00:00.000000Z",
                   "ends_at" => "2021-01-25T23:00:00.000000Z",
                   "active" => true
                 }
               }
             } = mutate_with_user(@edit_my_event_mutation, user, event: mutation_args)
    end
  end
end
