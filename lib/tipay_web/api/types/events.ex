defmodule TipayWeb.Api.Types.Events do
  @moduledoc """
  GraphQL Event types
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.EventsResolver
  alias TipayWeb.Api.Resolvers.EventAttachmentsResolver

  @desc """
  Filter for selecting finished events or those that have not been ended yet.
  To skip this filter, do not pass it at all.
  """
  enum :event_availability do
    value(:pending, description: "Pending Event, where ended_at date is in the future")
    value(:finished, description: "Finished Event, where ended_at date is in the past")
  end

  interface :public_event_interface do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :active, non_null(:boolean)

    field :attachments, non_null(list_of(non_null(:attachment))) do
      resolve(&EventAttachmentsResolver.event_attachments/3)
    end

    resolve_type(fn
      %{active: true}, _ -> :public_active_event
      %{active: false}, _ -> :public_pending_event
      _, _ -> nil
    end)
  end

  @desc "Public Event object which has been activated"
  object :public_active_event do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :short_description, non_null(:string)
    field :description, non_null(:string)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :active, non_null(:boolean)
    field :vendor_id, non_null(:id)

    field :attachments, non_null(list_of(non_null(:attachment))) do
      resolve(&EventAttachmentsResolver.event_attachments/3)
    end

    interface(:public_event_interface)
  end

  @desc "Public Pending Event object in inactive state"
  object :public_pending_event do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :active, non_null(:boolean)

    field :attachments, non_null(list_of(non_null(:attachment))) do
      resolve(&EventAttachmentsResolver.event_attachments/3)
    end

    interface(:public_event_interface)
  end

  @desc "Event object"
  object :event do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :short_description, non_null(:string)
    field :description, non_null(:string)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :active, non_null(:boolean)
    field :vendor_id, non_null(:id)

    field :offers, non_null(list_of(non_null(:offer))) do
      resolve(&EventsResolver.event_offers/3)
    end
  end

  @desc "Input for creating Event mutation"
  input_object :event_create_input do
    field :name, non_null(:string)
    field :short_description, non_null(:string)
    field :description, non_null(:string)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :active, non_null(:boolean)
    field :vendor_id, non_null(:id)
  end

  input_object :event_edit_input do
    field :id, non_null(:id)
    field :name, :string
    field :short_description, :string
    field :description, :string
    field :published_at, :datetime
    field :begins_at, :datetime
    field :ends_at, :datetime
    field :active, :boolean
  end

  @desc "Result of executing Event mutation"
  object :event_mutate_result do
    field :success, non_null(:boolean)
    field :event, :event
    field :errors, :json
  end

  @desc "Result of querying Event"
  object :event_query_result do
    field :success, non_null(:boolean)
    field :event, :event
    field :errors, :json
  end
end
