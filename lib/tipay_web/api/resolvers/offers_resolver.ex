defmodule TipayWeb.Api.Resolvers.OffersResolver do
  @moduledoc """
  GraphQL Offers resolver
  """
  alias Tipay.Events
  alias Tipay.Offers
  alias Tipay.Offers.Offer

  # TODO: filter with map of fields e.g. :id => fn -> maybe_filter_id (if present)
  def all_public_offers(_root, %{offer_filter: %{event_id: event_id}}, _info) do
    filters = fn query ->
      query
      |> Offers.filter_by_event(event_id)
    end

    offers = Offers.list_offers(filters)

    {:ok, offers}
  end

  def all_public_offers(_root, _args, _info) do
    offers = Offers.list_offers()

    {:ok, offers}
  end

  def my_offers(_root, %{offer_filter: %{event_id: event_id}}, %{context: %{current_user: user}}) do
    with :ok <- Bodyguard.permit(Tipay.Offers, :view_event_offer, user, %{event_id: event_id}) do
      offers = Offers.event_offers_list(event_id)

      {:ok, offers}
    end
  end

  def create_offer(_root, %{offer: args}, %{context: %{current_user: user}}) do
    with :ok <- Bodyguard.permit(Tipay.Offers, :create_offer, user, args),
         {:ok, %Offer{} = offer} <- Offers.create_offer(args) do
      {:ok, %{success: true, offer: offer}}
    else
      {:error, %Ecto.Changeset{} = error_changeset} -> {:error, error_changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  def edit_my_offer(_root, %{offer: %{id: offer_id} = args}, %{context: %{current_user: user}}) do
    with %Offer{} = offer <- Offers.get_offer_by_id(offer_id),
         :ok <- Bodyguard.permit(Tipay.Offers, :edit_my_offer, user, offer),
         {:ok, %Offer{} = offer} <- Offers.update_offer(offer, args) do
      {:ok, %{success: true, offer: offer}}
    else
      {:error, %Ecto.Changeset{} = error_changeset} -> {:error, error_changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_my_offer(_root, %{offer_id: offer_id}, %{context: %{current_user: user}}) do
    with %Offer{} = offer <- Offers.get_offer_by_id(offer_id),
         :ok <- Bodyguard.permit(Tipay.Offers, :delete_my_offer, user, offer),
         {:ok, %Offer{} = offer} <- Offers.delete_offer(offer) do
      {:ok, %{success: true, offer: offer}}
    else
      {:error, %Ecto.Changeset{} = error_changeset} -> {:error, error_changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  def offer_event(%Offer{} = parent, _args, _info) do
    event = Events.get_event_by_id(parent.event_id)
    {:ok, event}
  end
end
