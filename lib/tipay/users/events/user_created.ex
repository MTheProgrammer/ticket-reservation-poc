defmodule Tipay.Users.Events.UserCreated do
  @type t :: %__MODULE__{
          user_id: binary(),
          email: String.t()
        }

  defstruct user_id: nil,
            email: nil

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end
end
