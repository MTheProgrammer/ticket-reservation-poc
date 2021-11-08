defmodule TipayWeb.Api.Mutations.Events do
  @moduledoc """
  Events GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.EventsResolver

  object :event_mutations do
    @desc "Create new Event assigned to specific Vendor."
    field :create_event, non_null(:event_mutate_result) do
      arg(:event, non_null(:event_create_input))

      resolve(&EventsResolver.create_event/3)
    end

    @desc "Edit Event with permission check."
    field :edit_my_event, non_null(:event_mutate_result) do
      arg(:event, non_null(:event_edit_input))

      resolve(&EventsResolver.edit_my_event/3)
    end
  end
end
