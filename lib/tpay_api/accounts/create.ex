defmodule TpayApi.Accounts.Create do
  @type t :: %__MODULE__{
          offer_code: String.t(),
          email: String.t(),
          # IDK why, but TPay API stores tax id as int instead of string
          tax_id: integer(),
          regon: String.t(),
          krs: String.t(),
          legal_form: integer(),
          category_id: integer(),
          notify_by_email: boolean(),
          website: [TpayApi.Accounts.Structs.Website.t()],
          address: [TpayApi.Accounts.Structs.Address.t()],
          person: [TpayApi.Accounts.Structs.Person.t()]
        }
  @behaviour TpayApi.Request

  alias TpayApi.Accounts.Create
  alias TpayApi.Accounts.Structs.Website
  alias TpayApi.Accounts.Structs.Address
  alias TpayApi.Accounts.Structs.Person

  defstruct offer_code: nil,
            email: nil,
            tax_id: nil,
            regon: nil,
            krs: nil,
            legal_form: 3,
            category_id: 78,
            notify_by_email: false,
            website: nil,
            address: nil,
            person: nil

  def endpoint, do: "/accounts"

  @spec new(data :: map()) :: t()
  def new(data \\ %{}) do
    struct!(__MODULE__, data)
  end

  def to_api_payload(%Create{} = request) do
    %{
      offerCode: request.offer_code,
      email: request.email,
      taxId: request.tax_id,
      regon: request.regon,
      krs: request.krs,
      legalForm: request.legal_form,
      categoryId: request.category_id,
      notifyByEmail: request.notify_by_email,
      website: Enum.map(request.website, &Website.to_api_payload/1),
      address: Enum.map(request.address, &Address.to_api_payload/1),
      person: Enum.map(request.person, &Person.to_api_payload/1)
    }
  end
end
