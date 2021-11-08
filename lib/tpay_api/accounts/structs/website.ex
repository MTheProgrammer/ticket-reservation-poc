defmodule TpayApi.Accounts.Structs.Website do
  @type t :: %__MODULE__{
          name: String.t(),
          friendly_name: String.t(),
          description: String.t(),
          url: String.t(),
          settings: TpayApi.Accounts.Structs.Settings.t() | nil
        }

  alias TpayApi.Accounts.Structs.Website
  alias TpayApi.Accounts.Structs.Settings

  defstruct name: nil,
            friendly_name: nil,
            description: nil,
            url: nil,
            settings: nil

  def to_api_payload(%Website{} = request) do
    %{
      name: request.name,
      friendlyName: request.friendly_name,
      description: request.description,
      url: request.url,
      settings: Settings.to_api_payload(request.settings)
    }
  end

  def to_api_payload(_), do: nil
end
