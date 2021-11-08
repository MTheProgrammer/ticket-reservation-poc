defmodule Tipay.Reservations.TransactionConverter do
  alias Tipay.Transactions.Transaction
  alias TipayWeb.Router.Helpers
  alias TipayWeb.Router.FrontendRoutes

  def transaction_to_tpay_transaction(%Transaction{} = transaction) do
    map_part_tasks = [
      Task.async(fn -> get_transaction_details(transaction) end),
      Task.async(fn -> get_payer(transaction) end),
      Task.async(fn -> get_callbacks(transaction) end)
    ]

    Task.await_many(map_part_tasks)
    |> Enum.reduce(%{}, fn map_part, result ->
      Map.merge(result, map_part)
    end)
  end

  defp get_transaction_details(
         %Transaction{
           id: transaction_id,
           payment_method_id: payment_method_id
         } = transaction
       ) do
    %{
      amount: Money.to_string(Transaction.sum_amount(transaction), symbol: false),
      crc: transaction_id,
      description: "Transaction: #{transaction_id}",
      hidden_description: "#{transaction_id}",
      pay: %{
        group_id: payment_method_id
      }
    }
  end

  defp get_payer(%Transaction{
         user_id: user_id
       }) do
    case Tipay.Users.get_user_by_id(user_id) do
      %{email: email, first_name: first_name, last_name: last_name} ->
        %{
          payer: %{
            email: email,
            name: "#{first_name} #{last_name}"
          }
        }

      _ ->
        raise "user for transaction not found"
    end
  end

  defp get_callbacks(%Transaction{id: transaction_id}) do
    %{
      callbacks: %{
        payer_urls: %{
          success: FrontendRoutes.get_transaction_payment_success(transaction_id),
          error: FrontendRoutes.get_transaction_payment_error(transaction_id)
        },
        notification: %{
          url: Helpers.notification_url(TipayWeb.Endpoint, :notify),
          email: "test@tpay.com"
        }
      }
    }
  end
end
