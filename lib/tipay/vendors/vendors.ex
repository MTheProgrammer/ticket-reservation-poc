defmodule Tipay.Vendors do
  @moduledoc """
  The Vendors context.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.Users.User
  alias Tipay.Vendors.Vendor
  alias Tipay.Vendors.VendorUser

  defdelegate authorize(action, user, params), to: Tipay.Vendors.OwnerPolicy

  @doc """
  Returns the list of vendors.

  ## Examples

      iex> list_vendors()
      [%Vendor{}, ...]

  """
  def list_vendors do
    Repo.all(Vendor)
  end

  def list_active_vendors do
    query =
      from v in Vendor,
        where: v.active

    Repo.all(query)
  end

  def active?(vendor_id) when is_binary(vendor_id) do
    query =
      from v in Vendor,
        where: v.active,
        where: v.id == ^vendor_id

    Repo.exists?(query)
  end

  @doc """
  Returns the list of vendors belonging to specified user
  """

  def list_user_vendors(%User{id: user_id}) do
    list_user_vendors(user_id)
  end

  def list_user_vendors(user_id) do
    query =
      from v in Vendor,
        left_join: vu in VendorUser,
        on: vu.vendor_id == v.id,
        where: vu.user_id == ^user_id

    Repo.all(query)
  end

  @doc """
  Gets a single vendor.

  Raises `Ecto.NoResultsError` if the Vendor does not exist.

  ## Examples

      iex> get_vendor!(123)
      %Vendor{}

      iex> get_vendor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vendor!(id), do: Repo.get!(Vendor, id)

  def get_vendor_by_id(id) when is_binary(id), do: Repo.get_by(Vendor, id: id)

  @doc """
  Creates a vendor.

  ## Examples

      iex> create_vendor(%{field: value})
      {:ok, %Vendor{}}

      iex> create_vendor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vendor(attrs \\ %{}) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vendor.

  ## Examples

      iex> update_vendor(vendor, %{field: new_value})
      {:ok, %Vendor{}}

      iex> update_vendor(vendor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vendor(%Vendor{} = vendor, attrs) do
    vendor
    |> Vendor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vendor.

  ## Examples

      iex> delete_vendor(vendor)
      {:ok, %Vendor{}}

      iex> delete_vendor(vendor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vendor(%Vendor{} = vendor) do
    Repo.delete(vendor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vendor changes.

  ## Examples

      iex> change_vendor(vendor)
      %Ecto.Changeset{data: %Vendor{}}

  """
  def change_vendor(%Vendor{} = vendor, attrs \\ %{}) do
    Vendor.changeset(vendor, attrs)
  end

  @doc """
  Returns the list of vendors_users.

  ## Examples

      iex> list_vendors_users()
      [%VendorUser{}, ...]

  """
  def list_vendors_users do
    Repo.all(VendorUser)
  end

  @doc """
  Gets a single vendor_user.

  Raises `Ecto.NoResultsError` if the Vendor user does not exist.

  ## Examples

      iex> get_vendor_user!(123)
      %VendorUser{}

      iex> get_vendor_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vendor_user!(id), do: Repo.get!(VendorUser, id)

  @doc """
  Get Vendor that belongs to user
  """
  def get_vendor_for_user(%User{id: user_id}, vendor_id)
      when is_binary(user_id) and is_binary(vendor_id) do
    query =
      from v in Vendor,
        join: vu in VendorUser,
        on: vu.vendor_id == v.id,
        where: v.id == ^vendor_id,
        where: vu.user_id == ^user_id

    Repo.one(query)
  end

  @doc """
  Creates a vendor_user.

  ## Examples

      iex> create_vendor_user(%{field: value})
      {:ok, %VendorUser{}}

      iex> create_vendor_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vendor_user(attrs \\ %{}) do
    %VendorUser{}
    |> VendorUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a vendor_user.

  ## Examples

      iex> delete_vendor_user(vendor_user)
      {:ok, %VendorUser{}}

      iex> delete_vendor_user(vendor_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vendor_user(%VendorUser{} = vendor_user) do
    Repo.delete(vendor_user)
  end
end
