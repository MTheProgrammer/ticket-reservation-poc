defmodule TpayApi.Transactions.Checksum do
  alias Tipay.Transactions.Transaction
  alias TpayApi.Config

  def build_merchant_id(%{} = request, %Transaction{vendor_id: vendor_id}) do
    vendor = Tipay.Vendors.get_vendor!(vendor_id)

    case Tipay.VendorsTpay.get_vendor_credentials(vendor) do
      %Tipay.Tpay.Credentials{merchant_id: merchant_id} ->
        Map.put(request, :id, merchant_id)

      _ ->
        raise "vendor not found"
    end
  end

  def build_checksum(
        %{id: _merchant_id, tr_id: _tr_id, tr_amount: _amount, tr_crc: _crc} = request,
        security_code
      )
      when not is_nil(security_code) do
    checksum =
      calculate_checksum(
        request,
        security_code
      )

    request
    |> Map.put(:md5sum, checksum)
  end

  def build_checksum(_, _) do
    raise "missing fields for checksum"
  end

  def calculate_checksum(
        %{id: merchant_id, tr_id: tr_id, tr_amount: tr_amount, tr_crc: tr_crc},
        security_code
      )
      when not is_nil(security_code) do
    [merchant_id, tr_id, tr_amount, tr_crc, security_code]
    |> Enum.join()
    |> hash()
  end

  def validate_checksum(md5sum, %{} = checksum_components) do
    checksum = build_checksum(checksum_components, Config.security_code())
    checksum[:md5sum] === md5sum
  end

  defp hash(data) do
    :crypto.hash(:md5, data) |> Base.encode16(case: :lower)
  end
end
