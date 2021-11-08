defmodule TipayWeb.ApiCase do
  @moduledoc """
  GraphQL base test module
  """
  use ExUnit.CaseTemplate

  using(opts) do
    schema = Keyword.get(opts, :schema, TipayWeb.Api.Schema)
    api_path = Keyword.get(opts, :api_path, "/api")

    quote do
      @__schema__ unquote(schema)
      @__api_path__ unquote(api_path)
      @endpoint TipayWeb.Endpoint

      alias Ecto.Adapters.SQL.Sandbox
      alias Tipay.Repo

      use ExUnit.Case

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import TipayWeb.ConnCase
      import Tipay.DataCase
      import Tipay.Factory
      import TipayWeb.ApiCase
      import Phoenix.ConnTest

      import Money.Sigils

      @moduletag :graphql

      def run_query(document, variables, context \\ %{})

      @doc """
      Raises ArgumentException when developer forgets to include `document` param or when uses invalid module attribute.

      ## Examples

        iex> run_query(@invalid_argument, user, %{})
        ** (ArgumentError) Empty query body. Make sure that you've provided apropriate query in the test.
      """
      def run_query(document, variables, context) when is_nil(document) do
        raise(
          ArgumentError,
          "Empty query body. Make sure that you've provided apropriate query in the test."
        )
      end

      def run_query(document, variables, context) do
        # opts = case normalize_variables(variables) do
        #   %{variables: variables, file: file} -> [variables: variables, file: file, context: context]
        #   variables -> [variables: variables, context: context]
        # end

        opts = [variables: normalize_variables(variables), context: context]

        case Absinthe.run!(document, @__schema__, opts) do
          %{errors: errors, data: data} when is_nil(data) -> {:error, errors}
          %{data: data} -> data
          error -> raise Absinthe.ExecutionError, message: error
        end
      end

      # TODO: invert, default should raise, do not raise on demand
      # see how are options defined for standard libraries
      # TODO: there is a problem if query returns error
      # Test fails with nil (e.g. when types do not match or not enough fields are provided)
      def run_query_raising(document, variables, context) do
        opts = [variables: normalize_variables(variables), context: context]

        case Absinthe.run!(document, @__schema__, opts) do
          %{errors: errors, data: data} when is_nil(data) ->
            raise Absinthe.ExecutionError, message: errors

          %{data: data} ->
            data

          error ->
            raise Absinthe.ExecutionError, message: error
        end
      end

      def query(document, variables) do
        run_query(document, variables)
      end

      def mutate(document, variables) do
        run_query(document, variables)
      end

      def query(document, user, variables) do
        query_with_user(document, user, variables)
      end

      def query_with_user(document, user, variables) do
        run_query(document, variables, %{current_user: user})
      end

      def mutate_with_user(document, user, variables) do
        query_with_user(document, user, variables)
      end

      def query_over_router(conn, query, variables \\ %{}) do
        conn
        |> Plug.Conn.put_req_header("content-type", "application/json")
        |> post(@__api_path__, Jason.encode!(%{query: query, variables: variables}))
      end

      # TODO: allow uploading multiple files (now its just one hardcoded file)
      def query_over_router_file(conn, query, variables \\ %{}, file, context) do
        conn
        |> Plug.Conn.put_req_header("content-type", "multipart/form-data")
        |> post(@__api_path__, query: query, variables: variables, file: file)
      end

      setup tags do
        :ok = Sandbox.checkout(Tipay.Repo)

        Absinthe.Test.prime(@__schema__)

        unless tags[:async] do
          Sandbox.mode(Tipay.Repo, {:shared, self()})
        end

        [conn: Phoenix.ConnTest.build_conn()]
      end
    end
  end

  def normalize_variables([]), do: []

  def normalize_variables([id | _tail] = list) when is_binary(id) or is_integer(id), do: list

  def normalize_variables([head | _tail] = list) when is_map(head) do
    Enum.map(list, &normalize_variables/1)
  end

  def normalize_variables(%Money{} = money) do
    Money.to_string(money)
  end

  # def normalize_variables(
  #       %Plug.Upload{content_type: content_type, filename: filename, path: path} = upload
  #     ) do
  #   # %{content_type: content_type, filename: filename, path: path}
  #   # |> Jason.encode!()
  #   %{
  #     variables: %{content_type: content_type, filename: filename, path: path},
  #     file: path
  #   }
  # end

  def normalize_variables(variables) when is_map(variables) or is_list(variables) do
    Map.new(variables, fn {key, val} -> {camelize_key(key), normalize_variables(val)} end)
  end

  def normalize_variables(atom) when is_atom(atom) and atom not in [true, false, nil],
    do: to_string(atom) |> String.upcase()

  def normalize_variables(other), do: other

  def camelize_key(key) do
    to_string(key)
    |> Absinthe.Utils.camelize(lower: true)
  end

  def get_ids(actual) do
    Enum.map(actual, fn
      %{"id" => id} when is_binary(id) -> String.to_integer(id)
      %{id: id} when is_integer(id) -> id
    end)
    |> Enum.sort()
  end

  @doc """
  Converts string keyed map to :atom keyed map
  """
  def keys_to_atoms(%{} = map) do
    map
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  def keys_to_atoms(maps) when is_list(maps) do
    maps
    |> Enum.map(&keys_to_atoms/1)
  end
end
