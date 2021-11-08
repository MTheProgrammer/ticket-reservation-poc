defmodule Tipay.Events.OwnerPolicy do
  @moduledoc """
  User owner policy for the Events
  """
  @behaviour Bodyguard.Policy

  alias Tipay.Events.Event
  alias Tipay.Users.User

  def authorize(:list_events, _, _), do: true

  def authorize(action, %User{id: user_id}, %Event{user_id: user_id})
      when action in [:view_my_event, :edit_my_event],
      do: true

  def authorize(_, _, _), do: false
end
