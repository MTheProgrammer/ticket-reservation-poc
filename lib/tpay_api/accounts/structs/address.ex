defmodule TpayApi.Accounts.Structs.Address do
  @type t :: %__MODULE__{
          friendly_name: String.t(),
          name: String.t(),
          street: String.t(),
          house_number: String.t(),
          room_number: String.t(),
          postal_code: String.t(),
          city: String.t(),
          country: String.t(),
          phone: String.t(),
          is_main: boolean(),
          is_correspondence: boolean(),
          is_invoice: boolean()
        }

  alias TpayApi.Accounts.Structs.Address

  defstruct friendly_name: nil,
            name: nil,
            street: nil,
            house_number: nil,
            room_number: nil,
            postal_code: nil,
            city: nil,
            country: nil,
            phone: nil,
            is_main: false,
            is_correspondence: false,
            is_invoice: false

  def to_api_payload(%Address{} = request) do
    %{
      friendlyName: request.friendly_name,
      name: request.name,
      street: request.street,
      houseNumber: request.house_number,
      roomNumber: request.room_number,
      postalCode: request.postal_code,
      city: request.city,
      country: request.city,
      phone: request.phone,
      isMain: request.is_main,
      isCorrespondence: request.is_correspondence,
      isInvoice: request.is_invoice
    }
  end

  def to_api_payload(_), do: nil
end
