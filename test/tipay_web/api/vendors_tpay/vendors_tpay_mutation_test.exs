defmodule TipayWeb.Api.VendorsTpayMutationTest do
  @moduledoc """
  Vendors Tpay GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  import Tesla.Mock

  @base_url "https://api.tpay.com"

  defmacrop url(path) do
    @base_url <> path
  end

  defp oauth_mock(%{method: :post, url: url("/oauth/auth")}) do
    json(%{
      "issued_at" => 1_526_995_718,
      "scope" => "read write",
      "expires_in" => 7200,
      "token_type" => "Bearer",
      "client_id" => "testclient",
      "access_token" => "1b19469129b2c22459f3d4cd71275fca4b2f94da"
    })
  end

  defp success_accounts_mock(%{method: :post, url: url("/accounts")}) do
    json(%{
      "result" => "success",
      "requestId" => "85136c79cbf9fe36bb9",
      "id" => "mc_6UvbBjehvHXA7vfD",
      "offerCode" => "OFF3R",
      "email" => "jan.kowalski@example.com",
      "taxId" => 3_774_716_081,
      "regon" => "092045117",
      "krs" => "0000160673",
      "legalForm" => 3,
      "categoryId" => 78,
      "notifyByEmail" => true,
      "verificationStatus" => 1,
      "activationLink" => "https://panel.tpay.com/Auth/Account/Activate/abcdefb542f4",
      "website" => [
        %{
          "posId" => "ps_6UvbBjehvHXA7vfD",
          "accountId" => "mc_6UvbBjehvHXA7vfD",
          "name" => "Przykładowe Zakupy Online",
          "friendlyName" => "Przykładowe Zakupy Online",
          "description" => "Zakupy online - rtv i agd",
          "url" => "https://google.com",
          "date" => %{
            "create" => "2019-06-28 15:35:40",
            "modification" => "2019-06-28 15:35:40"
          },
          "settings" => %{
            "confirmationCode" => "35bffcec75c2952ef1de680bb9627e24",
            "isTestMode" => false
          }
        }
      ],
      "address" => [
        %{
          "addressId" => "ar_6UvbBjehvHXA7vfD",
          "friendlyName" => "Adres Korespondencyjny",
          "name" => "Example Sp. z o.o.",
          "street" => "ul. Przykładowa",
          "houseNumber" => "44b",
          "roomNumber" => "2",
          "postalCode" => "00-001",
          "city" => "Warszawa",
          "country" => "PL",
          "phone" => "00123456",
          "isMain" => true,
          "isCorrespondence" => true,
          "isInvoice" => true
        }
      ],
      "person" => [
        %{
          "personId" => "pr_6UvbBjehvHXA7vfD",
          "name" => "Jan",
          "surname" => "Kowalski",
          "nationality" => "PL",
          "sharesPct" => 35.12,
          "pesel" => "03080869897",
          "isBeneficiary" => false,
          "isRepresentative" => false,
          "isContactPerson" => false,
          "isAuthorizedPerson" => false,
          "pepStatement" => false,
          "dateOfBirth" => "1990-01-01 00:00:00",
          "countryOfBirth" => "PL",
          "typeOfDocument" => 0,
          "serialNumber" => "string",
          "expiryDate" => "2020-01-01 00:00:00",
          "issuingAuthority" => "string",
          "contact" => [
            %{
              "type" => 1,
              "contact" => "mail@example.com"
            }
          ]
        }
      ],
      "apiCredentials" => [
        %{
          "clientId" => "23157-36xf5ed3bbd7a9996",
          "clientSecret" => "9d7ca19746f34510ebe5846df009132f60a3aff2c62323b5245c7ccff0e4ca3f"
        }
      ],
      "transactionApiCredentials" => %{
        "merchantId" => 12345,
        "apiKey" => "d3767876b1221a4e1e5359d59a69cad4e9a48e42",
        "apiPassword" => "password1234"
      }
    })
  end

  describe "Vendors Tpay Credentials mutation" do
    @assign_credentials_to_vendor_mutation """
    mutation($vendorTpayCredentials: VendorTpayCredentialsInput!) {
      assignTpayCredentialsToVendor(vendorTpayCredentials: $vendorTpayCredentials) {
        success
        tpayCredentials {
          apiKey
          merchantId
        }
        errors
      }
    }
    """

    @valid_params %{
      api_key: "asdqwezxc",
      api_password: "secretPwd",
      merchant_id: "123456"
    }

    test "assign Tpay Credentials to Vendor for logged in user" do
      vendor_user = insert(:vendor_user)
      user = vendor_user.user
      vendor = vendor_user.vendor

      mutation_args = Map.put(@valid_params, :vendor_id, vendor.id)

      assert %{
               "assignTpayCredentialsToVendor" => %{
                 "errors" => nil,
                 "success" => true,
                 "tpayCredentials" => %{
                   "apiKey" => "asdqwezxc",
                   "merchantId" => "123456"
                 }
               }
             } =
               mutate_with_user(@assign_credentials_to_vendor_mutation, user,
                 vendor_tpay_credentials: mutation_args
               )
    end
  end

  describe "register new credentials in TPay for Vendor" do
    setup do
      mock(fn %{url: url} = request ->
        case url do
          url("/oauth/auth") -> oauth_mock(request)
          url("/accounts") -> success_accounts_mock(request)
        end
      end)

      :ok
    end

    @register_vendor_in_tpay_mutation """
    mutation($vendorId: ID!, $account: TpayAccountCreateInput!) {
      registerVendorInTpay(vendorId: $vendorId, account: $account) {
        success
        tpayCredentials {
          apiKey
          merchantId
        }
        errors
      }
    }
    """

    test "register account for Vendor in TPay" do
      vendor_user = insert(:vendor_user)
      user = vendor_user.user
      vendor = vendor_user.vendor

      account = %{
        offer_code: "TEST OFFER CODE 123",
        email: "vendor@domain.com",
        tax_id: "3774716081",
        regon: nil,
        krs: nil,
        legal_form: 3,
        category_id: 78,
        websites: [
          %{
            name: "Przykładowe Zakupy Online",
            friendly_name: "Przykładowe Zakupy Online",
            description: "Zakupy online - rtv i agd",
            url: "https://przykladowezakupy.pl"
          }
        ],
        addresses: [
          %{
            friendly_name: "Adres Korespondencyjny",
            name: "Example Sp. z o.o.",
            street: "ul. Przykładowa",
            house_number: "44b",
            room_number: "2",
            postal_code: "00-001",
            city: "Warszawa",
            country: "PL",
            phone: "00123456",
            is_main: true,
            is_correspondence: true,
            is_invoice: true
          }
        ],
        persons: [
          %{
            name: "Jan",
            surname: "Kowalski",
            is_representative: true,
            is_contact_person: true,
            contacts: [
              %{
                type: 1,
                contact: "mail@example.com"
              }
            ]
          }
        ]
      }

      assert %{
               "registerVendorInTpay" => %{
                 "errors" => nil,
                 "success" => true,
                 "tpayCredentials" => %{
                   "apiKey" => "d3767876b1221a4e1e5359d59a69cad4e9a48e42",
                   "merchantId" => "12345"
                 }
               }
             } =
               mutate_with_user(@register_vendor_in_tpay_mutation, user,
                 vendor_id: vendor.id,
                 account: account
               )
    end
  end
end
