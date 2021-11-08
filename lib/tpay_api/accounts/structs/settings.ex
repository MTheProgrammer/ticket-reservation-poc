defmodule TpayApi.Accounts.Structs.Settings do
  @type t :: %__MODULE__{
          confirmation_code: String.t(),
          is_test_mode: boolean()
        }

  alias TpayApi.Accounts.Structs.Settings

  defstruct confirmation_code: nil,
            is_test_mode: false

  def to_api_payload(%Settings{} = request) do
    %{
      confirmationCode: request.confirmation_code,
      isTestMode: request.is_test_mode
    }
  end

  def to_api_payload(_), do: nil
end
