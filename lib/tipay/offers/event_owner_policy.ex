defmodule Tipay.Offers.EventOwnerPolicy do
  @moduledoc """
  Offers owner policy grouped by Events owners
  """
  @behaviour Bodyguard.Policy

  alias Tipay.Events
  alias Tipay.Events.Event
  alias Tipay.Offers.Offer
  alias Tipay.Users.User

  def authorize(:list_offers, _, _), do: true

  def authorize(action, %User{id: user_id}, %{event_id: event_id})
      when action in [:create_offer, :view_event_offer] do
    event = Events.get_event_by_id(event_id)

    case check_event(event, user_id) do
      true -> true
      {:error, _} = error -> error
      _ -> {:error, %{message: "you are not allowed to create an offer for this event"}}
    end
  end

  def authorize(action, %User{id: user_id}, %Offer{event_id: event_id})
      when action in [:edit_my_offer, :delete_my_offer] do
    event = Events.get_event_by_id(event_id)

    case check_event(event, user_id) do
      true -> true
      {:error, _} = error -> error
      _ -> {:error, %{message: "you are not allowed to modify an offer for this event"}}
    end
  end

  def authorize(_, _, _), do: false

  defp check_event(%Event{} = event, user_id) do
    check_event_owner(user_id, event)
  end

  defp check_event(_, _) do
    {:error, %{message: "event does not exist"}}
  end

  defp check_event_owner(user_id, %Event{user_id: user_id}), do: true

  defp check_event_owner(_, _), do: false
end
