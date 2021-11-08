defmodule TipayWeb.Api.Types.Offers do
  @moduledoc """
  GraphQL Offers types
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.OffersResolver

  enum :offer_status do
    value(:available)
    value(:sold_out)
  end

  @desc "Input for filtering Public Offers list"
  input_object :public_offer_filter_input do
    field :event_id, :id
  end

  # TODO: use uuid instead of id https://github.com/absinthe-graphql/absinthe/wiki/Scalar-Recipes#uuid-using-ectouuid
  object :public_offer do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:money)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :status, non_null(:offer_status)

    field :event, non_null(:event) do
      resolve(&OffersResolver.offer_event/3)
    end
  end

  object :offer do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:money)
    field :available_qty, non_null(:integer)
    field :sold_qty, non_null(:integer)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :status, non_null(:offer_status)
    field :is_editable, non_null(:boolean)

    field :event, non_null(:event) do
      resolve(&OffersResolver.offer_event/3)
    end
  end

  @desc "Input for creating Offer mutation"
  input_object :offer_create_input do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:money_input)
    field :available_qty, non_null(:integer)
    field :published_at, non_null(:datetime)
    field :begins_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :event_id, non_null(:id)
  end

  @desc "Input for editing Offer mutation"
  input_object :offer_edit_input do
    field :id, non_null(:id)
    field :name, :string
    field :description, :string
    field :price, :money_input
    field :available_qty, :integer
    field :published_at, :datetime
    field :begins_at, :datetime
    field :ends_at, :datetime
    field :event_id, :id
  end

  @desc "Input for filtering Offers list"
  input_object :offer_filter_input do
    field :id, :id
    field :event_id, :id
  end

  @desc "Result of executing Offer mutation"
  object :offer_mutate_result do
    field :success, non_null(:boolean)
    field :offer, :offer
    field :errors, :json
  end
end
