defmodule TipayWeb.Router.FrontendRoutes do
  @spec get_transaction_payment_success(binary()) :: String.t()
  def get_transaction_payment_success(transaction_id),
    do: transaction_payment_link(transaction_id, :success)

  @spec get_transaction_payment_error(binary()) :: String.t()
  def get_transaction_payment_error(transaction_id),
    do: transaction_payment_link(transaction_id, :error)

  defp transaction_payment_link(transaction_id, _) when not is_binary(transaction_id),
    do: raise("transaction id is required")

  defp transaction_payment_link(transaction_id, link) do
    [
      Application.fetch_env!(:tipay, :system_url),
      transaction_id,
      "/",
      link
    ]
    |> Enum.join("")
  end
end
