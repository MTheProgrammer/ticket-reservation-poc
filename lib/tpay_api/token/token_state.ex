defmodule TpayApi.TokenState do
  @moduledoc """
  Each client has a different OAuth token, so this Token State stores multiple tokens for each client_id.

  TODO: Not implemented
  """

  use Agent

  @doc """
  Starts a new Token State storage.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Gets a value by `client_id`.
  """
  def get(client_id) do
    Agent.get(__MODULE__, &Map.get(&1, client_id))
  end

  @doc """
  Puts the `value` for the given `client_id`.
  """
  def put(client_id, value) do
    Agent.update(__MODULE__, &Map.put(&1, client_id, value))
  end
end
