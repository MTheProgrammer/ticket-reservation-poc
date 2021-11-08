defmodule Tipay.Tpay do
  @moduledoc """
  The Tpay context.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.Tpay.Credentials

  @doc """
  Gets a single credentials.

  Raises `Ecto.NoResultsError` if the Credentials does not exist.

  ## Examples

      iex> get_credentials!(123)
      %Credentials{}

      iex> get_credentials!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credentials!(id), do: Repo.get!(Credentials, id)

  def get_credentials_by_id(id), do: Repo.get_by(Credentials, id: id)

  def get_credentials_by_merchant_id(merchant_id),
    do: Repo.get_by(Credentials, merchant_id: merchant_id)

  @doc """
  Creates credentials.

  ## Examples

      iex> create_credentials(%{field: value})
      {:ok, %Credentials{}}

      iex> create_credentials(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credentials(attrs \\ %{}) do
    %Credentials{}
    |> Credentials.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates credentials.

  ## Examples

      iex> update_credentials(credentials, %{field: new_value})
      {:ok, %Credentials{}}

      iex> update_credentials(credentials, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credentials(%Credentials{} = credentials, attrs) do
    credentials
    |> Credentials.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes credentials.

  ## Examples

      iex> delete_credentials(credentials)
      {:ok, %Credentials{}}

      iex> delete_credentials(credentials)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credentials(%Credentials{} = credentials) do
    Repo.delete(credentials)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credentials changes.

  ## Examples

      iex> change_credentials(credentials)
      %Ecto.Changeset{source: %Credentials{}}

  """
  def change_credentials(%Credentials{} = credentials) do
    Credentials.changeset(credentials, %{})
  end
end
