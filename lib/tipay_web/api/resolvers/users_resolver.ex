defmodule TipayWeb.Api.Resolvers.UsersResolver do
  @moduledoc """
  Users GraphQL Resolver
  """
  alias Tipay.Users
  alias Tipay.Users.Auth
  alias Tipay.Users.User
  alias TipayWeb.Guardian

  def my_user(_root, _args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  def edit_my_user(_root, %{user: args}, %{context: %{current_user: my_user}}) do
    with {:ok, %User{} = user} <- Users.update_user(my_user, args) do
      {:ok, %{success: true, user: user}}
    end
  end

  def change_my_user_password(
        _root,
        %{
          password: password,
          password_confirmation: password_confirmation,
          current_password: current_password
        },
        %{context: %{current_user: my_user}}
      ) do
    with {:ok, %User{} = user} <-
           Users.update_user_password(
             my_user,
             %{
               password: password,
               password_confirmation: password_confirmation,
               current_password: current_password
             }
           ) do
      {:ok, %{success: true, user: user}}
    end
  end

  def create_user(_root, %{user: args}, _info) do
    with {:ok, %User{} = user} <- Users.create_user(args) do
      {:ok, %{success: true, user: user}}
    end
  end

  def login(_root, %{email: email, password: password}, _info) do
    with {:ok, %User{} = user} <- Auth.login_with_email_pass(email, password),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
      {:ok, %{success: true, token: jwt}}
    else
      _ ->
        Bcrypt.no_user_verify()
        {:error, :bad_request}
    end
  end

  def request_user_password_reset(_root, %{email: email}, _info) do
    case Users.create_reset_password_token(email) do
      {:ok, _} -> {:ok, %{success: true, email: email}}
      {:error, _} -> {:ok, %{success: true, email: email}}
    end
  end

  def check_reset_password_token(_root, %{email: email, token: token}, _info) do
    case Users.is_valid_reset_password_token(email, token) do
      {:ok, _} ->
        {:ok, true}

      {:error, _} ->
        {:ok, false}
    end
  end

  def reset_password(
        _root,
        %{
          reset_user_password:
            %{
              email: email,
              password: _password,
              password_confirmation: _password_confirmation,
              token: token
            } = email_and_passwords
        },
        _info
      ) do
    with {:ok, _} <- Users.is_valid_reset_password_token(email, token),
         :ok <- update_user_password(email_and_passwords) do
      {:ok, %{success: true, email: email}}
    else
      _ -> error_invalid_token()
    end
  end

  defp update_user_password(%{email: email} = passwords) do
    user = Users.get_user_by_email(email)
    update_user_password(user, passwords)
  end

  defp update_user_password(%User{} = user, %{} = passwords) do
    case Users.update_user_reseted_password(user, passwords) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  defp update_user_password(error, _) do
    error
  end

  defp error_invalid_token do
    {:error, :invalid_token}
  end
end
