defmodule Tipay.UserTicketTokensTest do
  use Tipay.DataCase, async: true

  alias Tipay.UserTicketTokens

  describe "user_ticket_tokens" do
    alias Tipay.UserTicketTokens.UserTicketToken

    test "list_user_ticket_tokens/0 returns token of a specified user" do
      _not_expected_token = insert(:user_ticket_token)
      %{id: expected_id, user: user} = insert(:user_ticket_token)

      [result] = UserTicketTokens.list_user_ticket_tokens(user)

      assert %UserTicketToken{id: ^expected_id} = result
    end

    test "get_user_ticket_token!/1 returns the user_ticket_token with given id" do
      [user_ticket_token, _other] = insert_list(2, :user_ticket_token)

      result = UserTicketTokens.get_user_ticket_token!(user_ticket_token.id)

      assert %UserTicketToken{} = result
      assert result.id == user_ticket_token.id
    end

    test "get_user_ticket_token_by_id/1 returns the user_ticket_token with given id" do
      [user_ticket_token, _other] = insert_list(2, :user_ticket_token)

      result = UserTicketTokens.get_user_ticket_token_by_id(user_ticket_token.id)

      assert %UserTicketToken{} = result
      assert result.id == user_ticket_token.id
    end

    test "create_user_token/1 with valid data creates an user_ticket_token" do
      %{id: user_id} = insert(:user)

      attrs = %{
        name: "Test Token",
        status: :active,
        user_id: user_id
      }

      assert {:ok, %UserTicketToken{} = result} = UserTicketTokens.create_user_token(attrs)

      assert is_binary(result.id)
      assert result.name == attrs.name
      assert result.status == attrs.status
      assert result.user_id == attrs.user_id
    end
  end
end
