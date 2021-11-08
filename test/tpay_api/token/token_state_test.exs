defmodule TipayApi.TokenStateTest do
  use ExUnit.Case, async: true

  describe "TPay Token State" do
    alias TpayApi.TokenState

    test "stores token by client_id" do
      assert TokenState.get("123-456-asd") == nil

      TokenState.put("other-123", "expected-token")
      assert TokenState.get("other-123") == "expected-token"
    end
  end
end
