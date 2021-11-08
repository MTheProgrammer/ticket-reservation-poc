defmodule Tipay.UserTicketTokenFactory do
  @moduledoc """
  ExMachina User Ticket Token factory
  """
  defmacro __using__(_opts) do
    quote do
      def user_ticket_token_factory do
        user = build(:user)

        %Tipay.UserTicketTokens.UserTicketToken{
          name: sequence(:user_ticket_token, &"UserTicketToken #{&1}"),
          status: :active,
          user: user
        }
      end
    end
  end
end
