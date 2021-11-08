defmodule Tpay.Integration.TpayTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag :tpay_api

  setup do
    # TODO: setup sandbox api keys - passed by ENV vars

    :ok
  end

  test "authorize" do
    # TODO: implement
    # assert {:ok, %Tesla.Env{} = env} = Tpay.authorize(@valid_login, @valid_password)

    # assert env.status == 200

    # assert env.body == %{
    #          "issued_at" => 1_526_995_718,
    #          "scope" => "read write",
    #          "expires_in" => 7200,
    #          "token_type" => "Bearer",
    #          "client_id" => "testclient",
    #          "access_token" => "1b19469129b2c22459f3d4cd71275fca4b2f94da"
    #        }
  end
end
