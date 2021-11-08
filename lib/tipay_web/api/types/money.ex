defmodule TipayWeb.Api.Types.Money do
  @moduledoc """
  The `Money` type represents Money as amount and currency.
  Requires `{ :money, "~> 1.4" }`
  """
  use Absinthe.Schema.Notation

  input_object :money_input do
    field :amount, non_null(:integer)
    field :currency, non_null(:string)
  end

  object :money do
    field :amount, non_null(:integer)
    field :currency, non_null(:string)
  end
end
