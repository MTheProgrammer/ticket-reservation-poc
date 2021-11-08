defmodule TipayWeb.Api.Dev.UsersTest do
  use TipayWeb.ApiCase, async: true

  describe "Dev: reset user password" do
    @request_user_password_reset_mutation """
    mutation($email: String!) {
      devRequestUserPasswordReset(email: $email) {
        email
        token
        errors
        success
      }
    }
    """

    test "send reset user password link" do
      user = insert(:user)
      expected_email = user.email

      assert %{
               "devRequestUserPasswordReset" => %{
                 "errors" => nil,
                 "success" => true,
                 "email" => ^expected_email,
                 "token" => token
               }
             } =
               mutate(
                 @request_user_password_reset_mutation,
                 %{
                   email: user.email
                 }
               )

      assert not is_nil(token)
    end
  end
end
