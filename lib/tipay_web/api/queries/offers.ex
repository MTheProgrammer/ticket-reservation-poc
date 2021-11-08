defmodule TipayWeb.Api.Queries.Offers do
  @moduledoc """
  Offers GraphQL queries
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.OffersResolver

  object :offer_queries do
    @desc "Retrieve all public offers"
    field :all_public_offers, non_null(list_of(non_null(:public_offer))) do
      arg(:offer_filter, :public_offer_filter_input)

      resolve(&OffersResolver.all_public_offers/3)
    end

    @desc "Get all offers from Events belonging to User"
    field :my_offers, non_null(list_of(non_null(:offer))) do
      arg(:offer_filter, non_null(:offer_filter_input))

      resolve(&OffersResolver.my_offers/3)
    end
  end
end
