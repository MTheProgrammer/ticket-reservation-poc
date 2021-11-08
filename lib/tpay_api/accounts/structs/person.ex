defmodule TpayApi.Accounts.Structs.Person do
  @type t :: %__MODULE__{
          name: String.t(),
          surname: String.t(),
          nationality: String.t(),
          shares_pct: Decimal.t(),
          pesel: String.t(),
          is_beneficiary: boolean(),
          is_representative: boolean(),
          is_contact_person: boolean(),
          is_authorized_person: boolean(),
          pep_statement: boolean(),
          date_of_birth: String.t(),
          country_of_birth: String.t(),
          type_of_document: integer() | nil,
          serial_number: String.t(),
          expiry_date: NaiveDateTime.t(),
          issuing_authority: String.t(),
          contact: [TpayApi.Accounts.Structs.Contact.t()]
        }

  alias TpayApi.Accounts.Structs.Person
  alias TpayApi.Accounts.Structs.Contact

  defstruct name: nil,
            surname: nil,
            nationality: nil,
            shares_pct: 0,
            pesel: nil,
            is_beneficiary: false,
            is_representative: false,
            is_contact_person: false,
            is_authorized_person: false,
            pep_statement: false,
            date_of_birth: nil,
            country_of_birth: nil,
            type_of_document: nil,
            serial_number: nil,
            expiry_date: nil,
            issuing_authority: nil,
            contact: []

  def to_api_payload(%Person{} = request) do
    %{
      name: request.name,
      surname: request.surname,
      nationality: request.nationality,
      sharesPct: request.shares_pct,
      pesel: request.pesel,
      isBeneficiary: request.is_beneficiary,
      isRepresentative: request.is_representative,
      isContactPerson: request.is_contact_person,
      isAuthorizedPerson: request.is_authorized_person,
      pepStatement: request.pep_statement,
      dateOfBirth: request.date_of_birth,
      countryOfBirth: request.country_of_birth,
      typeOfDocument: request.type_of_document,
      serialNumber: request.serial_number,
      expiryDate: request.expiry_date,
      issuingAuthority: request.issuing_authority,
      contact: Enum.map(request.contact, &Contact.to_api_payload/1)
    }
  end

  def to_api_payload(_), do: nil
end
