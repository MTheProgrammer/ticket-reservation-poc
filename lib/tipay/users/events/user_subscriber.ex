defmodule Tipay.Users.Events.UserSubscriber do
  @moduledoc """
  Behaviour for user events subscribers
  """

  alias Tipay.Users.Events.UserCreated

  @callback user_created(%UserCreated{}) :: :ok | {:error, String.t()}
end
