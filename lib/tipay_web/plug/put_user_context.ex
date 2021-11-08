defmodule TipayWeb.Plug.PutUserContext do
  @moduledoc """
  Assigns current user from resolved JWT token
  """
  @behaviour Plug

  def init(config), do: config

  def call(conn, _) do
    user = conn.private[:guardian_default_resource]
    context = %{current_user: user}
    Absinthe.Plug.put_options(conn, context: context)
  end
end
