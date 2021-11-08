defmodule Tipay.Offers do
  @moduledoc """
  The Offers context.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.Offers.Offer

  defdelegate authorize(action, user, params), to: Tipay.Offers.EventOwnerPolicy

  @spec list_offers((Ecto.Query -> Ecto.Query)) :: [%Offer{}]
  @doc """
  Returns the list of offers.

  ## Examples

      iex> list_offers()
      [%Offer{}, ...]

  """
  def list_offers(filter \\ & &1) do
    Offer
    |> filter_out_unpublished_offers()
    |> filter.()
    |> order_by(asc: :begins_at)
    |> order_by(asc: :published_at)
    |> Repo.all()
    |> put_virtual_fields()
  end

  def event_offers_list(event_id) do
    Offer
    |> where(event_id: ^event_id)
    |> order_by(asc: :begins_at)
    |> order_by(asc: :published_at)
    |> Repo.all()
    |> put_virtual_fields()
  end

  defp put_virtual_fields(offers) when is_list(offers) do
    offers
    |> Enum.map(&Offer.put_virtual_fields/1)
  end

  def filter_by_event(query, event_id) do
    query
    |> where(event_id: ^event_id)
  end

  def filter_out_unpublished_offers(query) do
    query
    |> where([o], o.published_at <= fragment("now()"))
  end

  @doc """
  Gets a single offer.

  Raises `Ecto.NoResultsError` if the Offer does not exist.

  ## Examples

      iex> get_offer!(123)
      %Offer{}

      iex> get_offer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_offer!(id) do
    Repo.get!(Offer, id)
    |> Offer.put_virtual_fields()
  end

  def get_offer_by_id(id) do
    case Repo.get_by(Offer, id: id) do
      %Offer{} = offer ->
        offer
        |> Offer.put_virtual_fields()

      _ ->
        nil
    end
  end

  @spec get_offers_by_ids(list(identifier())) :: list(Offer)
  @doc """
  Get offers by ids
  """
  def get_offers_by_ids(offers_ids) when not is_nil(offers_ids) do
    Tipay.Offers.Offer
    |> where([o], o.id in ^offers_ids)
    |> Repo.all()
  end

  @doc """
  Creates a offer.

  ## Examples

      iex> create_offer(%{field: value})
      {:ok, %Offer{}}

      iex> create_offer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_offer(attrs \\ %{}) do
    %Offer{}
    |> Offer.create_changeset(attrs)
    |> Repo.insert()
    |> Offer.put_virtual_fields()
  end

  @doc """
  Updates a offer.

  ## Examples

      iex> update_offer(offer, %{field: new_value})
      {:ok, %Offer{}}

      iex> update_offer(offer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_offer(%Offer{} = offer, attrs) do
    offer
    |> Offer.update_changeset(attrs)
    |> Repo.update()
    |> Offer.put_virtual_fields()
  end

  @doc """
  Deletes a offer.

  ## Examples

      iex> delete_offer(offer)
      {:ok, %Offer{}}

      iex> delete_offer(offer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_offer(%Offer{sold_qty: sold_qty} = offer) when sold_qty > 0 do
    {:error,
     offer
     |> change_offer()
     |> Ecto.Changeset.add_error(
       :sold_qty,
       "deleting offers with already sold items is forbidden"
     )}
  end

  def delete_offer(%Offer{} = offer) do
    offer
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking offer changes.

  ## Examples

      iex> change_offer(offer)
      %Ecto.Changeset{source: %Offer{}}

  """
  def change_offer(%Offer{} = offer) do
    Offer.changeset(offer, %{})
  end

  def is_any_owned_by?(offer_ids, user_id) when is_list(offer_ids) and not is_nil(user_id) do
    Offer
    |> select(fragment("count(*) > 0"))
    |> join(:left, [o], e in Tipay.Events.Event, on: e.id == o.event_id and e.user_id == ^user_id)
    |> where([o], o.id in ^offer_ids)
    |> Repo.one!()
  end
end
