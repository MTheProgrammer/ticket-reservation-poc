defmodule TipayWeb.Api.UsersTest do
  use TipayWeb.ApiCase, async: true

  @valid_params %{
    email: "user@example.com",
    password: "oZ0r8%JOq9Zq^lxlB2fK",
    password_confirmation: "oZ0r8%JOq9Zq^lxlB2fK",
    first_name: "John",
    last_name: "Wick",
    nick: "jw",
    has_accepted_terms: true
  }

  @hash Bcrypt.hash_pwd_salt(@valid_params.password)

  describe "my_user query returns current user data" do
    @my_user_query """
    {
      myUser {
        email
        firstName
        lastName
        nick
      }
    }
    """

    test "returns list of existing offers" do
      user = insert(:user)

      %{
        "myUser" => queried_user
      } = query_with_user(@my_user_query, user, %{})

      assert queried_user == %{
               "email" => user.email,
               "firstName" => user.first_name,
               "lastName" => user.last_name,
               "nick" => user.nick
             }
    end
  end

  describe "create user mutation" do
    @create_user_mutation """
    mutation($user: UserCreateInput!) {
      createUser(user: $user) {
        success
        user {
          email
          first_name
          last_name
          nick
          has_accepted_terms
        }
        errors
      }
    }
    """

    test "creates a new user" do
      assert %{
               "createUser" => %{
                 "errors" => nil,
                 "success" => true,
                 "user" => %{
                   "email" => "user@example.com",
                   "first_name" => "John",
                   "last_name" => "Wick",
                   "nick" => "jw",
                   "has_accepted_terms" => true
                 }
               }
             } = mutate(@create_user_mutation, user: @valid_params)
    end

    test "prevents creating a new user with existing email" do
      insert(:user, email: @valid_params.email)

      assert %{
               "createUser" => %{
                 "errors" => %{"email" => "has already been taken"},
                 "success" => false,
                 "user" => nil
               }
             } = mutate(@create_user_mutation, user: @valid_params)
    end
  end

  describe "login user mutation" do
    @login_user_mutation """
    mutation($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        token
        errors
        success
      }
    }
    """

    test "login existing user returns token" do
      insert(:user, email: @valid_params.email, password_hash: @hash)

      assert %{
               "login" => %{
                 "errors" => nil,
                 "success" => true,
                 "token" => token
               }
             } =
               mutate(
                 @login_user_mutation,
                 %{email: @valid_params.email, password: @valid_params.password}
               )

      assert not is_nil(token) and byte_size(token) > 0
    end
  end

  describe "change my user password mutation" do
    @change_my_user_password_mutation """
    mutation(
      $password: String!,
      $passwordConfirmation: String!,
      $currentPassword: String!
    ) {
      changeMyUserPassword(
        password: $password,
        passwordConfirmation: $passwordConfirmation,
        currentPassword: $currentPassword
      ) {
        success
        user {
          email
          first_name
          last_name
          nick
        }
        errors
      }
    }
    """

    test "changes password for current logged in user" do
      user = insert(:user, email: @valid_params.email, password_hash: @hash)
      expected_email = @valid_params.email

      assert %{
               "changeMyUserPassword" => %{
                 "errors" => nil,
                 "success" => true,
                 "user" => %{
                   "email" => ^expected_email
                 }
               }
             } =
               mutate_with_user(
                 @change_my_user_password_mutation,
                 user,
                 %{
                   password: "n3wP4ssword",
                   password_confirmation: "n3wP4ssword",
                   current_password: @valid_params.password
                 }
               )
    end

    test "fails to change password for current logged in user" do
      user = insert(:user, email: @valid_params.email, password_hash: @hash)

      assert %{
               "changeMyUserPassword" => %{
                 "errors" => %{
                   "currentPassword" => "invalid password",
                   "passwordConfirmation" => "does not match confirmation"
                 },
                 "success" => false,
                 "user" => nil
               }
             } =
               mutate_with_user(
                 @change_my_user_password_mutation,
                 user,
                 %{
                   password: "n3wP4ssword",
                   password_confirmation: "wr0ngconfirm4tion",
                   current_password: "inv4lid curr3nt pwd"
                 }
               )
    end
  end

  describe "edit my user mutation" do
    @edit_my_user_params %{
      first_name: "Keanu",
      last_name: "Reeves"
    }

    @edit_my_user_mutation """
    mutation($user: UserEditInput!) {
      editMyUser(user: $user) {
        success
        user {
          first_name
          last_name
        }
        errors
      }
    }
    """
    test "updates current logged in user" do
      user = insert(:user)

      assert %{
               "editMyUser" => %{
                 "errors" => nil,
                 "success" => true,
                 "user" => %{
                   "first_name" => "Keanu",
                   "last_name" => "Reeves"
                 }
               }
             } = mutate_with_user(@edit_my_user_mutation, user, user: @edit_my_user_params)
    end
  end

  describe "reset user password" do
    @request_user_password_reset_mutation """
    mutation($email: String!) {
      requestUserPasswordReset(email: $email) {
        email
        errors
        success
      }
    }
    """

    test "send reset user password link" do
      user = insert(:user)
      expected_email = user.email

      assert %{
               "requestUserPasswordReset" => %{
                 "errors" => nil,
                 "success" => true,
                 "email" => ^expected_email
               }
             } =
               mutate(
                 @request_user_password_reset_mutation,
                 %{
                   email: user.email
                 }
               )
    end

    @check_reset_password_token_query """
    query($email: String!, $token: String!) {
      checkResetPasswordToken(email: $email, token: $token)
    }
    """
    test "query for valid reset password token resolves to true" do
      rp_token = insert(:reset_password_token)

      assert %{
               "checkResetPasswordToken" => true
             } =
               query(
                 @check_reset_password_token_query,
                 %{
                   email: rp_token.user.email,
                   token: rp_token.token
                 }
               )
    end

    test "query for expired reset password token resolves to false" do
      rp_token = insert(:reset_password_token)

      assert %{
               "checkResetPasswordToken" => false
             } =
               query(
                 @check_reset_password_token_query,
                 %{
                   email: "invalid_" <> rp_token.user.email,
                   token: "invalid_" <> rp_token.token
                 }
               )
    end

    @reset_user_password_mutation """
    mutation($resetUserPassword: ResetUserPasswordInput!) {
      resetUserPassword(resetUserPassword: $resetUserPassword) {
        email
        errors
        success
      }
    }
    """
    test "reset user password with valid reset password token" do
      rp_token = insert(:reset_password_token)
      user = rp_token.user
      expected_email = user.email

      assert %{
               "resetUserPassword" => %{
                 "errors" => nil,
                 "success" => true,
                 "email" => ^expected_email
               }
             } =
               mutate(
                 @reset_user_password_mutation,
                 resetUserPassword: %{
                   email: user.email,
                   token: rp_token.token,
                   password: "n3wp4ssw0rd",
                   password_confirmation: "n3wp4ssw0rd"
                 }
               )
    end
  end
end
