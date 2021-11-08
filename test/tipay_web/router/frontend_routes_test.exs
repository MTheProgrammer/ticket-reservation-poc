defmodule TipayWeb.Router.FrontendRoutesTest do
  @moduledoc """
  Frontend Routes test
  """
  use Tipay.DataCase, async: true

  describe "frontend routes" do
    alias TipayWeb.Router.FrontendRoutes

    test "get_transaction_payment_success\1 returns success url" do
      assert "https://test.tivent.eu/123-asd-qwe-456/success" =
               FrontendRoutes.get_transaction_payment_success("123-asd-qwe-456")
    end

    test "get_transaction_payment_error\1 returns error url" do
      assert "https://test.tivent.eu/123-asd-qwe-456/error" =
               FrontendRoutes.get_transaction_payment_error("123-asd-qwe-456")
    end
  end
end
