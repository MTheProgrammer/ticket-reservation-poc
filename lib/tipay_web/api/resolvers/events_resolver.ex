defmodule TipayWeb.Api.Resolvers.EventsResolver do
  @moduledoc """
  Events GraphQL Resolver
  """
  alias Tipay.Events
  alias Tipay.Events.Event
  alias Tipay.Offers
  alias Tipay.Users.User

  def create_event(_root, %{event: args}, %{context: %{current_user: %User{} = user}}) do
    args = Map.put(args, :user_id, user.id)

    case Events.create_event(args) do
      {:ok, %Event{} = event} ->
        {:ok, %{success: true, event: event}}

      error ->
        error
    end
  end

  def edit_my_event(_root, %{event: %{id: event_id} = args}, %{context: %{current_user: user}}) do
    args = Map.put(args, :user_id, user.id)

    result =
      event_id
      |> get_event
      |> permit_event(user)
      |> update_event(args)

    case result do
      {:ok, %Event{} = event} -> {:ok, %{success: true, event: event}}
      error -> error
    end
  end

  defp update_event({:ok, %Event{} = event}, args) do
    event
    |> Events.update_event(args)
  end

  defp update_event(error, _args) do
    error
  end

  def my_events(_root, args, %{context: %{current_user: %User{} = user}}) do
    availability = Map.get(args, :availability)
    vendor_id = Map.get(args, :vendor_id)

    events = Events.list_user_events(user, availability, vendor_id)
    {:ok, events}
  end

  def get_my_event(_root, %{event_id: event_id}, %{context: %{current_user: %User{} = user}}) do
    result =
      event_id
      |> get_event
      |> permit_event(user)

    case result do
      {:ok, %Event{} = event} -> {:ok, %{success: true, event: event}}
      error -> error
    end
  end

  defp get_event(event_id) do
    case Events.get_event_by_id(event_id) do
      %Event{} = event -> {:ok, event}
      _ -> {:error, :not_found}
    end
  end

  defp permit_event({:ok, %Event{} = event}, %User{} = user) do
    case Bodyguard.permit(Events, :view_my_event, user, event) do
      :ok -> {:ok, event}
      error -> error
    end
  end

  defp permit_event(error, _) do
    error
  end

  def published_events(_root, args, _info) do
    vendor_id = Map.get(args, :vendor_id)

    events = Events.list_published_events(vendor_id)
    {:ok, events}
  end

  def get_public_event(_root, %{event_id: event_id}, _info) do
    event = Events.get_public_event(event_id)
    {:ok, event}
  end

  def event_offers(%Event{} = parent, _args, _info) do
    offers = Offers.event_offers_list(parent.id)

    {:ok, offers}
  end
end
