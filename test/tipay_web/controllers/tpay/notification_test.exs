defmodule TipayWeb.Tpay.NotificationTest do
  use TipayWeb.ConnCase

  alias TpayApi.Transactions.Checksum
  alias TpayApi.Config

  # TODO: test this request
  # %{"id" => "46042", "md5sum" => "4be35168b430e397389821aec42d3a70", "test_mode" => "1", "tr_amount" => "20.00", "tr_crc" => "", "tr_date" => "2021-02-11 20:00:13", "tr_desc" => "Transaction: 61", "tr_email" => "mc@mailinator.com", "tr_error" => "none", "tr_id" => "TR-13A0-3651K3X", "tr_paid" => "20.00", "tr_status" => "TRUE"}
  describe "test notify" do
    test "returns TRUE when data is valid", %{conn: conn} do
      transaction = insert(:transaction, status: :pending)
      crc = transaction.id
      vendor = transaction.vendor
      vendor_credentials = insert(:vendors_tpay_vendor_credentials, vendor: vendor)
      credentials = vendor_credentials.credentials
      amount = Tipay.Transactions.Transaction.sum_amount(transaction).amount

      checksum =
        Checksum.build_checksum(
          %{
            id: credentials.merchant_id,
            tr_id: "TRANS-1234",
            tr_amount: amount,
            tr_crc: crc
          },
          Config.security_code()
        )

      conn =
        post(conn, Routes.notification_path(conn, :notify), %{
          "id" => credentials.merchant_id,
          "tr_id" => "TRANS-1234",
          "tr_date" => "2020-01-01 00:00:00",
          "tr_crc" => "#{crc}",
          "md5sum" => checksum[:md5sum],
          "tr_amount" => amount,
          "tr_paid" => amount,
          "tr_desc" => "ticket payment for the concert",
          "tr_status" => "TRUE",
          "tr_error" => "none",
          "tr_email" => "customer@example.com",
          "test_mode" => "0"
        })

      assert text_response(conn, 200) =~ "TRUE"
      assert %{status: :paid} = Tipay.Transactions.get_by_crc!(crc)
    end

    # TODO: handle cancelation and failed payments - as transaction reverse
    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, Routes.post_path(conn, :create), post: @invalid_attrs)
    #   assert html_response(conn, 200) =~ "New Post"
    # end
  end
end
