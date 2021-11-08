defmodule TipayWeb.Api.Middleware.TransformErrors do
  @moduledoc """
  Handles GrqphQL errors returned from resolvers.
  Errors are transformed into apropriate format, which contains errors key
  """
  @behaviour Absinthe.Middleware

  import Absinthe.Utils
  alias TipayWeb.ErrorHelpers

  def call(res, _) do
    with %{errors: [error]} <- res do
      %{res | errors: [], value: handle_error(error)}
    end
  end

  def handle_error(%Ecto.Changeset{} = changeset) do
    %{success: false, errors: transform_errors(changeset)}
  end

  @doc """
  Handle case where multiple objects are processed and it is necessary to know which one failed
  """
  def handle_error(%{changeset: %Ecto.Changeset{} = changeset, id: id}) do
    %{success: false, errors: %{"message" => transform_errors(changeset), "id" => id}}
  end

  def handle_error(errors) when is_map(errors) do
    %{success: false, errors: errors}
  end

  def handle_error(:unauthenticated) do
    %{success: false, errors: %{msg: "unauthenticated"}}
  end

  def handle_error(:unauthorized) do
    %{success: false, errors: %{msg: "unauthorized"}}
  end

  def handle_error(:bad_request) do
    %{success: false, errors: %{msg: "bad request"}}
  end

  def handle_error(:not_found) do
    %{success: false, errors: %{msg: "not found"}}
  end

  defp transform_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
    |> normalize_map()
  end

  defp normalize_error(list) when is_list(list), do: Enum.join(list, " ")

  defp normalize_error(map) when is_map(map) do
    normalize_map(map)
  end

  defp normalize_map(map) do
    Map.new(map, fn {key, value} -> {format_key(key), normalize_error(value)} end)
  end

  defp format_key(key) do
    key
    |> to_string
    |> camelize(lower: true)
  end
end
