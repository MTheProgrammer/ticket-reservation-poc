defmodule Payment.Money do
  import Ecto.Changeset

  def validate_money(%Ecto.Changeset{} = changeset, field) do
    changeset
    |> validate_change(field, &is_amount_positive/2)
    |> validate_change(field, &currency_exists/2)
  end

  defp is_amount_positive(_, %{amount: amount}) when amount > 0, do: []

  defp is_amount_positive(_, %{amount: amount}) when amount > 0,
    do: [amount: "must be greater than 0"]

  defp currency_exists(_, %Money{currency: currency}) do
    case Money.Currency.exists?(currency) do
      true -> []
      _ -> [currency: "invalid currency"]
    end
  end
end
