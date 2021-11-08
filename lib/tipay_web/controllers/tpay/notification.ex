defmodule TipayWeb.Tpay.Notification do
  @moduledoc """
  Notification handles response from TPay about transaction updates
  """
  use TipayWeb, :controller

  def notify(conn, %{
        "wallet" => "masterpass",
        "masterpass" => "1"
      }) do
    text(conn, "Masterpass is not implemented")
  end

  def notify(conn, %{"tr_status" => "CHARGEBACK"}) do
    text(conn, "Chargeback is not implemented")
  end

  def notify(conn, %{"tr_error" => "surcharge"}) do
    # TODO: handle surcharge (underpayment)
    text(conn, "Handling surcharge is not implemented")
  end

  def notify(conn, %{
        "id" => merchant_id,
        "tr_id" => tr_id,
        "tr_date" => _transaction_created_date,
        "tr_crc" => crc,
        "tr_amount" => amount,
        "tr_paid" => paid,
        "tr_desc" => _desc,
        "tr_status" => tr_status,
        "tr_error" => error,
        "tr_email" => _email,
        "md5sum" => md5sum
      })
      when error in ["none", "overpay"] and tr_status in ["TRUE", "PAID"] do
    # TODO: get transaction by CRC (add method to repo and column with crc)

    case process_correct_notification(%{
           id: merchant_id,
           tr_id: tr_id,
           tr_crc: get_crc(crc),
           tr_amount: amount,
           paid: paid,
           md5sum: md5sum
         }) do
      {:ok, _} -> text(conn, "TRUE")
      {:error, error} -> text(conn, error)
    end
  end

  def notify(conn, _params) do
    text(conn, "Invalid Params")
  end

  defp get_crc(crc) when is_binary(crc) do
    crc
  end

  defp get_crc(_) do
    raise "invalid crc"
  end

  defp process_correct_notification(
         %{
           id: _merchant_id,
           tr_crc: tr_crc
         } = params
       ) do
    case Tipay.Transactions.get_by_crc!(tr_crc) do
      %Tipay.Transactions.Transaction{} = transaction ->
        case maybe_update_transaction_status(transaction, params) do
          {:ok, _} = success_result -> success_result
          {:error, _} -> {:error, "Failed to update transaction status"}
        end

      _ ->
        {:error, "invalid transaction crc - not found"}
    end
  end

  defp maybe_update_transaction_status(
         %Tipay.Transactions.Transaction{} = transaction,
         %{} = params
       ) do
    validation_result =
      transaction
      |> convert_to_tpay_transaction()
      |> validate_transaction(params)

    case validation_result do
      {:ok, _} ->
        Tipay.Transactions.update_transaction_status(transaction, :paid)

      _ ->
        validation_result
    end
  end

  defp convert_to_tpay_transaction(%Tipay.Transactions.Transaction{} = transaction) do
    request = get_args_from_tpay_transaction(transaction)
    amount = request.amount.amount

    request
    |> Map.put(:amount, amount)
    |> TpayApi.Transactions.Checksum.build_merchant_id(transaction)
  end

  defp get_args_from_tpay_transaction(%Tipay.Transactions.Transaction{} = transaction) do
    %{
      amount: Tipay.Transactions.Transaction.sum_amount(transaction),
      description: "Payment for transaction: #{transaction.id}",
      crc: transaction.id
    }
  end

  defp validate_transaction(
         %{} = transaction,
         %{
           id: _merchant_id,
           md5sum: md5sum,
           tr_id: _tr_id,
           tr_amount: _tr_amount,
           tr_crc: _tr_crc
         } = checksum_components
       ) do
    case TpayApi.Transactions.Checksum.validate_checksum(md5sum, checksum_components) do
      true -> {:ok, transaction}
      _ -> {:error, "invalid md5sum:" <> "#{md5sum} #{}"}
    end
  end

  defp get_merchant_security_code(merchant_id) do
    case Tipay.Tpay.get_credentials_by_merchant_id(merchant_id) do
      %Tipay.Tpay.Credentials{} = credentials -> {:ok, credentials.api_password}
      _ -> {:error, "merchant not found"}
    end
  end
end
