defmodule TipayWeb.Api.Queries.Events do
  @moduledoc """
  Events GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.EventsResolver

  object :event_queries do
    @desc "Returns all publicly available events."
    field :published_events, non_null(list_of(non_null(:public_event_interface))) do
      arg(:vendor_id, :id)
      resolve(&EventsResolver.published_events/3)
    end

    @desc "Returns publicly available event. Returns null when event is unavailable or does not exist."
    field :get_public_event, :public_event_interface do
      arg(:event_id, non_null(:id))

      resolve(&EventsResolver.get_public_event/3)
    end

    @desc "Returns all Events available to edit by the current user. Filter by Event availability status or vendor_id."
    field :my_events, non_null(list_of(non_null(:event))) do
      arg(:availability, :event_availability)
      arg(:vendor_id, :id)

      resolve(&EventsResolver.my_events/3)
    end

    @desc "Returns Event available to edit by the current user"
    field :get_my_event, non_null(:event_query_result) do
      arg(:event_id, non_null(:id))

      resolve(&EventsResolver.get_my_event/3)
    end
  end
end
