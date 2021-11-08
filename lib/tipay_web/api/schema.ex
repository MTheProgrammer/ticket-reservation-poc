defmodule TipayWeb.Api.Schema do
  @moduledoc """
  GraphQL Schema
  """
  use Absinthe.Schema

  alias TipayWeb.Api.Middleware
  alias TipayWeb.Api.Mutations
  alias TipayWeb.Api.Queries
  alias TipayWeb.Api.Types

  @unprotected_mutations [
    :login,
    :create_user,
    :request_user_password_reset,
    :reset_user_password
  ]

  @unprotected_queries [
    :check_reset_password_token,
    :published_events,
    :get_public_event,
    :get_event_documents,
    :all_public_offers
  ]

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(Types.JSON)
  import_types(Types.Money)

  import_types(Types.Attachments)
  import_types(Types.Events)
  import_types(Types.EventAttachments)
  import_types(Types.UserTicketTokens)
  import_types(Types.Users)
  import_types(Types.DevUsers)
  import_types(Types.Offers)
  import_types(Types.Vendors)
  import_types(Types.VendorsTpay)
  import_types(Types.Tickets)

  import_types(Types.Payments)
  import_types(Types.TPay)
  import_types(Types.Transactions)

  import_types(Queries.Events)
  import_types(Queries.Offers)
  import_types(Queries.Transactions)
  import_types(Queries.Users)
  import_types(Queries.Vendors)
  import_types(Queries.VendorsTpay)
  import_types(Queries.Tickets)

  import_types(Mutations.DevUsers)
  import_types(Mutations.Events)
  import_types(Mutations.EventAttachments)
  import_types(Mutations.Offers)
  import_types(Mutations.Transactions)
  import_types(Mutations.Users)
  import_types(Mutations.Vendors)
  import_types(Mutations.VendorsTpay)
  import_types(Mutations.Tickets)

  query do
    import_fields(:event_queries)
    import_fields(:offer_queries)
    import_fields(:transaction_queries)
    import_fields(:user_queries)
    import_fields(:vendor_queries)
    import_fields(:vendors_tpay_queries)
    import_fields(:ticket_queries)
  end

  mutation do
    import_fields(:dev_user_mutations)
    import_fields(:event_mutations)
    import_fields(:event_attachments_mutations)
    import_fields(:offer_mutations)
    import_fields(:transaction_mutations)
    import_fields(:user_mutations)
    import_fields(:vendors_mutations)
    import_fields(:vendors_tpay_mutations)
    import_fields(:ticket_mutations)
  end

  # Dev
  @dev_mutations [:dev_request_user_password_reset]

  def middleware(middleware, %{identifier: identifier}, %{identifier: :mutation})
      when identifier in @dev_mutations,
      do: middleware ++ [Middleware.TransformErrors]

  # end of Dev

  def middleware(middleware, %{identifier: identifier}, %{identifier: :mutation})
      when identifier in @unprotected_mutations,
      do: middleware ++ [Middleware.TransformErrors]

  def middleware(middleware, %{identifier: identifier}, %{identifier: :query})
      when identifier in @unprotected_queries,
      do: middleware ++ [Middleware.TransformErrors]

  def middleware(middleware, _field, %{identifier: :mutation}) do
    [Middleware.Authenticate | middleware] ++ [Middleware.TransformErrors]
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: identifier})
      when identifier in [:query, :subscription] do
    [Middleware.Authenticate | middleware]
  end

  # if it's any other object keep things as is
  def middleware(middleware, _field, _object), do: middleware
end
