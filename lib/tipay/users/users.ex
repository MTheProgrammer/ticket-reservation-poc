defmodule Tipay.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.Users.ResetPasswordToken
  alias Tipay.Users.User

  @token_expire_time 60

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_id(id), do: Repo.get_by(User, id: id)

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(
        attrs \\ %{},
        event_handlers \\ [
          Tipay.UserTicketTokens.EventHandlers.User,
          Tipay.Vendors.EventHandlers.User
        ]
      ) do
    result =
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, user} ->
        dispatch_user_created_event(user, event_handlers)
        result

      _ ->
        result
    end
  end

  defp dispatch_user_created_event(%User{id: user_id, email: email}, event_handlers) do
    Enum.map(
      event_handlers,
      fn handler ->
        handler.user_created(%Tipay.Users.Events.UserCreated{user_id: user_id, email: email})
      end
    )
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update user password if required field :current_password is valid
  """
  def update_user_password(%User{} = user, attrs) do
    user
    |> User.update_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update user password after password reset - thus it does not require :current_password
  """
  def update_user_reseted_password(%User{} = user, attrs) do
    user
    |> User.update_reseted_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Creates reset password token for given email (if user exists)
  """
  def create_reset_password_token(email) do
    get_user_by_email(email)
    |> try_create_rp_token()
  end

  defp try_create_rp_token(%User{} = user) do
    rp_token =
      generate_rp_token_hash()
      |> create_rp_token(user.id)

    {:ok, rp_token.token}
  end

  defp try_create_rp_token(nil) do
    {:error, :user_not_found}
  end

  defp create_rp_token(token, user_id) do
    %ResetPasswordToken{}
    |> ResetPasswordToken.changeset(%{user_id: user_id, token: token})
    |> Repo.insert!(
      on_conflict: [
        set: [
          token: token
        ]
      ],
      conflict_target: :user_id
    )
  end

  defp generate_rp_token_hash do
    salt = :crypto.strong_rand_bytes(16)

    :crypto.hash(:sha512, salt)
    |> Base.encode16()
  end

  @doc """
  Use this function only for retriveing token from db and sending it to a customer, e.g. in reset password email
  To verify whether user has provided apropriate reset password token, use `is_valid_reset_password_token\2`
  """
  def get_reset_password_token_by_email(email) do
    with %User{} = user <- get_user_by_email(email),
         %ResetPasswordToken{} = rp_token <- Repo.get_by(ResetPasswordToken, user_id: user.id) do
      rp_token.token
    else
      _ -> nil
    end
  end

  @doc """
  Validates whether provided pair User has not expired reset password token
  """
  def is_valid_reset_password_token(%User{} = user, token) do
    is_user_token_not_expired(user, token)
  end

  def is_valid_reset_password_token(email, token) when not is_nil(email) and not is_nil(token) do
    get_user_by_email(email)
    |> is_valid_reset_password_token(token)
  end

  def is_valid_reset_password_token(_, _) do
    {:error, :user_not_found}
  end

  defp is_user_token_not_expired(%User{} = user, token) do
    is_user_token_not_expired(user.id, token)
  end

  defp is_user_token_not_expired(user_id, token) do
    query_reset_password_token_not_expired(user_id, token)
    |> Repo.exists?()
    |> get_token_expiration_query_result()
  end

  defp get_token_expiration_query_result(result) when result == true do
    {:ok, true}
  end

  defp get_token_expiration_query_result(_) do
    {:error, :token_expired}
  end

  defp query_reset_password_token_not_expired(user_id, token) do
    from rpt in ResetPasswordToken,
      where:
        rpt.user_id == ^user_id and
          rpt.token == ^token and
          rpt.updated_at >=
            fragment(
              "timezone('utc', now() - interval '? minutes')::timestamp",
              @token_expire_time
            )
  end
end
