defmodule TipayWeb.Api.Mutations.Offers do
  @moduledoc """
  Offers GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.OffersResolver

  object :offer_mutations do
    @desc "Create new offer bound to Event"
    field :create_offer, non_null(:offer_mutate_result) do
      arg(:offer, non_null(:offer_create_input))

      resolve(&OffersResolver.create_offer/3)
    end

    @desc "Edit offer if current user has appropriate permissions."
    field :edit_my_offer, non_null(:offer_mutate_result) do
      arg(:offer, non_null(:offer_edit_input))

      resolve(&OffersResolver.edit_my_offer/3)
    end

    @desc "Delete offer if current user has appropriate permissions."
    field :delete_my_offer, non_null(:offer_mutate_result) do
      arg(:offer_id, non_null(:id))

      resolve(&OffersResolver.delete_my_offer/3)
    end
  end
end
