defmodule Tipay.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.Events.Event
  alias Tipay.Vendors
  alias Tipay.Users.User
  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Tipay.Events.OwnerPolicy

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  def list_published_events(vendor_id \\ nil) do
    Event
    |> filter_out_unpublished_events()
    |> maybe_filter_vendor(vendor_id)
    |> order_by(asc: :begins_at)
    |> Repo.all()
  end

  def list_user_events(%User{} = user, availability \\ nil, vendor_id \\ nil) do
    Event
    |> filter_user(user)
    |> maybe_filter_availability(availability)
    |> maybe_filter_vendor(vendor_id)
    |> default_order()
    |> Repo.all()
  end

  @doc """
  Pending events are actually available events and not yet finished
  """
  def list_pending_events do
    Event
    |> filter_pending_events()
    |> default_order()
    |> Repo.all()
  end

  def list_completed_events do
    Event
    |> filter_completed_events()
    |> default_order()
    |> Repo.all()
  end

  defp default_order(query) do
    query
    |> order_by(desc: :begins_at)
  end

  defp filter_user(query, %User{} = user) do
    query
    |> where([e], e.user_id == ^user.id)
  end

  defp maybe_filter_vendor(query, vendor_id) when is_binary(vendor_id) do
    query
    |> where([e], e.vendor_id == ^vendor_id)
  end

  defp maybe_filter_vendor(query, _vendor_id), do: query

  defp maybe_filter_availability(query, availability) do
    case availability do
      :pending -> filter_pending_events(query)
      :finished -> filter_completed_events(query)
      _ -> query
    end
  end

  defp filter_pending_events(query) do
    query
    |> where([e], e.ends_at > fragment("now()"))
  end

  defp filter_completed_events(query) do
    query
    |> where([e], e.ends_at <= fragment("now()"))
  end

  defp filter_out_unpublished_events(query) do
    query
    |> where([e], e.published_at <= fragment("now()"))
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  def get_event_by_id(id), do: Repo.get(Event, id)

  def get_public_event(id) do
    Event
    |> where([e], e.id == ^id)
    |> filter_out_unpublished_events()
    |> Repo.one()
  end

  @doc """
  Creates an event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> permit_modifying_event_for_vendor
    |> Repo.insert()
  end

  @doc """
  Updates an event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.update_changeset(attrs)
    |> Repo.update()
  end

  defp permit_modifying_event_for_vendor(%Changeset{changes: %{vendor_id: vendor_id}} = changeset) do
    case Vendors.active?(vendor_id) do
      true ->
        changeset

      false ->
        Changeset.add_error(
          changeset,
          :vendor_id,
          "event's vendor must be active"
        )
    end
  end

  defp permit_modifying_event_for_vendor(changeset) do
    changeset
  end

  @doc """
  Deletes an event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end
end
