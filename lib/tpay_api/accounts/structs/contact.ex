defmodule TpayApi.Accounts.Structs.Contact do
  @type t :: %__MODULE__{
          type: integer(),
          contact: String.t()
        }

  alias TpayApi.Accounts.Structs.Contact

  defstruct type: 1,
            contact: nil

  def to_api_payload(%Contact{} = request) do
    %{
      type: request.type,
      contact: request.contact
    }
  end

  def to_api_payload(_), do: nil
end
