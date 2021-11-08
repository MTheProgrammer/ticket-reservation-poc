defmodule Tipay.Repo do
  use Ecto.Repo,
    otp_app: :tipay,
    adapter: Ecto.Adapters.Postgres

  defoverridable get: 2, get: 3

  def get(query, id, opts \\ []) do
    super(query, id, opts)
  rescue
    Ecto.Query.CastError -> nil
  end

  defoverridable get_by: 2, get_by: 3

  def get_by(query, id, opts \\ []) do
    super(query, id, opts)
  rescue
    Ecto.Query.CastError -> nil
  end
end
