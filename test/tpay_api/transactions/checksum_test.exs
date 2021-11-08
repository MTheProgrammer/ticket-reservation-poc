defmodule TpayApi.Transactions.ChecksumTest do
  use Tipay.DataCase, async: true

  alias TpayApi.Transactions.Checksum

  describe "TPay Checksum" do
    test "build_checksum/2 puts md5sum field with calculated checksum" do
      request =
        Checksum.build_checksum(
          %{
            id: "123456",
            tr_id: "TRANS-12345",
            tr_amount: 123.45,
            tr_crc: "33344"
          },
          "unknown"
        )

      md5sum_parts = "123456TRANS-12345123.4533344unknown"
      expected_md5sum = :crypto.hash(:md5, md5sum_parts) |> Base.encode16(case: :lower)

      assert %{md5sum: ^expected_md5sum} = request
    end
  end
end
