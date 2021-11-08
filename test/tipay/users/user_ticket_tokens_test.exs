defmodule Tipay.Users.UserTicketTokensTest do
  use Tipay.DataCase, async: true

  alias Tipay.Users
  alias Tipay.Users.User
  alias Tipay.UserTicketTokens
  alias Tipay.UserTicketTokens.UserTicketToken

  describe "user_ticket_tokens user events" do
    test "create_user/2 creates also new user_ticket_token" do
      user_desc = build(:user)

      attrs = Map.from_struct(user_desc)

      assert {:ok, %User{} = user} = Users.create_user(attrs)
      assert [%UserTicketToken{}] = UserTicketTokens.list_user_ticket_tokens(user)
    end
  end
end
