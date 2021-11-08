defmodule Tipay.UsersTest do
  @moduledoc """
  Users context test
  """
  use Tipay.DataCase, async: true

  alias Tipay.Users

  describe "users" do
    alias Tipay.Users.User

    @invalid_attrs %{
      password_hash: nil,
      first_name: nil,
      id_number: nil,
      last_name: nil,
      email: nil,
      password: nil,
      password_confirmation: nil
    }

    defp drop_password_fields(%User{} = user) do
      %{
        user
        | current_password: nil,
          password: nil,
          password_confirmation: nil,
          password_hash: nil
      }
    end

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Users.list_users() == [%{user | password: nil, password_confirmation: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Users.get_user!(user.id) == %{user | password: nil, password_confirmation: nil}
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = insert(:user)

      assert Users.get_user_by_email(user.email) == %{
               user
               | password: nil,
                 password_confirmation: nil
             }
    end

    test "create_user/1 with valid data creates a user" do
      user_desc = build(:user)

      assert {:ok, %User{} = user} =
               Users.create_user(%{
                 email: user_desc.email,
                 first_name: user_desc.first_name,
                 last_name: user_desc.last_name,
                 nick: user_desc.nick,
                 has_accepted_terms: user_desc.has_accepted_terms
               })

      assert user.first_name == user_desc.first_name
      assert user.last_name == user_desc.last_name
      assert user.nick == user_desc.nick
      assert user.email == user_desc.email
      assert user.has_accepted_terms == user_desc.has_accepted_terms
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Users.create_user(@invalid_attrs)

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               nick: ["can't be blank"],
               has_accepted_terms: ["please accept terms", "can't be blank"]
             } = errors_on(changeset)
    end

    test "create_user/1 with invalid password_confirmation returns error changeset" do
      user_desc = build(:user)

      attrs = %{
        email: user_desc.email,
        first_name: user_desc.first_name,
        last_name: user_desc.last_name,
        nick: user_desc.nick,
        has_accepted_terms: user_desc.has_accepted_terms,
        password: "some password",
        password_confirmation: "wrong confirmed password"
      }

      assert {:error, _} = Users.create_user(attrs)
    end

    test "create_user/1 with duplicated email returns error changeset" do
      email = "smith@web.net"
      _mr_smith = insert(:user, email: email)
      mrs_smith = build(:user, email: email)

      assert {:error, %Ecto.Changeset{} = changeset} =
               mrs_smith
               |> Map.from_struct()
               |> Users.create_user()

      assert %{
               email: ["has already been taken"]
             } = errors_on(changeset)
    end

    test "create_user/1 with duplicated nick returns error changeset" do
      nick = "smith"
      _mr_smith = insert(:user, nick: nick)
      mrs_smith = build(:user, nick: nick)

      assert {:error, %Ecto.Changeset{} = changeset} =
               mrs_smith
               |> Map.from_struct()
               |> Users.create_user()

      assert %{
               nick: ["has already been taken"]
             } = errors_on(changeset)
    end

    test "update_user/2 with valid data updates the user - except email and has_accepted_terms" do
      original_user = insert(:user)
      user_update_desc = build(:user)

      assert {:ok, %User{} = user} =
               Users.update_user(original_user, %{
                 email: user_update_desc.email,
                 first_name: user_update_desc.first_name,
                 last_name: user_update_desc.last_name,
                 nick: user_update_desc.nick,
                 has_accepted_terms: 0,
                 password: "some password",
                 # TODO: update password as standalone method (with password confirmation and current password)
                 password_confirmation: "some password"
               })

      assert user.email == original_user.email
      assert user.first_name == user_update_desc.first_name
      assert user.last_name == user_update_desc.last_name
      assert user.nick == original_user.nick
      assert user.has_accepted_terms == original_user.has_accepted_terms
    end

    test "update_user/2 with invalid data returns error changeset" do
      user =
        insert(:user)
        |> drop_password_fields()

      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "update_user_password/2 with same new password and confirmation updates user password" do
      password = "some3P4ssw0rd"
      # TODO: user factory with password hash
      password_hash = Bcrypt.hash_pwd_salt(password)
      user = insert(:user, password_hash: password_hash)

      update_password_attrs = %{
        password: "zaq1@WSX",
        password_confirmation: "zaq1@WSX",
        current_password: password
      }

      assert {:ok, %User{} = updated_user} =
               Users.update_user_password(user, update_password_attrs)

      assert updated_user.password_hash !== user.password_hash
    end

    test "update_user_password/2 with different new password and confirmation returns error changeset" do
      user = %{insert(:user) | password: nil, password_confirmation: nil}

      update_password_attrs = %{
        password: "zaq1@WSX",
        password_confirmation: "123QWEasd"
      }

      assert {:error, %Ecto.Changeset{} = changeset} =
               Users.update_user_password(user, update_password_attrs)

      assert %{
               password_confirmation: ["does not match confirmation"]
             } = errors_on(changeset)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  describe "users reset password" do
    test "create_reset_password_token/1 creates reset password token for user identified by given email" do
      user = insert(:user)
      assert {:ok, _} = Users.create_reset_password_token(user.email)
    end

    test "create_reset_password_token/1 updates reset password token if it has been already created" do
      user = insert(:user)
      first_token = Users.create_reset_password_token(user.email)
      another_token = Users.create_reset_password_token(user.email)

      assert first_token !== another_token
    end

    test "create_reset_password_token/1 returns error when no user is assigned to a given email" do
      email = "mail@domain.com"
      assert {:error, :user_not_found} = Users.create_reset_password_token(email)
    end

    test "get_reset_password_token_by_email/1 returns reset password token if it has been already created" do
      user = build(:user)
      reset_password_token = insert(:reset_password_token, user: user)
      expected_token = reset_password_token.token

      assert expected_token == Users.get_reset_password_token_by_email(user.email)
    end

    test "get_reset_password_token_by_email/1 returns null if it does not exists for given email" do
      user = insert(:user)

      assert is_nil(Users.get_reset_password_token_by_email(user.email))
    end

    test "is_valid_reset_password_token/2 returns true when token is not expired" do
      # TODO: fix test with date - to set exact date in psql.
      # Now we assume that test is no runing for longer time than 1 sec
      fake_updated_at =
        DateTime.utc_now()
        |> DateTime.add(-50 * 60, :second)

      reset_password_token = insert(:reset_password_token, updated_at: fake_updated_at)
      user = reset_password_token.user

      assert {:ok, true} =
               Users.is_valid_reset_password_token(user.email, reset_password_token.token)
    end

    test "is_valid_reset_password_token/2 returns error when token has expired" do
      # TODO: fix test with date - to set exact date in psql
      fake_updated_at =
        DateTime.utc_now()
        |> DateTime.add(-100 * 60, :second)

      reset_password_token = insert(:reset_password_token, updated_at: fake_updated_at)
      user = reset_password_token.user

      assert {:error, :token_expired} =
               Users.is_valid_reset_password_token(user.email, reset_password_token.token)
    end

    test "is_valid_reset_password_token/2 returns error when token is not found" do
      # TODO: fix test with date - to set exact date in psql
      fake_updated_at =
        DateTime.utc_now()
        |> DateTime.add(-50 * 60, :second)

      reset_password_token = insert(:reset_password_token, updated_at: fake_updated_at)
      user = reset_password_token.user

      invalid_email = "invalid" <> user.email
      invalid_token = "invalid_" <> reset_password_token.token

      assert {:error, :user_not_found} =
               Users.is_valid_reset_password_token(invalid_email, reset_password_token.token)

      assert {:error, :token_expired} =
               Users.is_valid_reset_password_token(user.email, invalid_token)
    end
  end
end
