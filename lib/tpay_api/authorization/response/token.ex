defmodule TpayApi.Authorization.Response.Token do
  @type t :: %__MODULE__{
          issued_at: integer(),
          scope: String.t(),
          expires_in: integer(),
          token_type: String.t(),
          client_id: String.t(),
          access_token: String.t()
        }
  alias TpayApi.Authorization.Response.Token

  defstruct issued_at: nil,
            scope: nil,
            expires_in: nil,
            token_type: nil,
            client_id: nil,
            access_token: nil

  def from_response(%{
        "issued_at" => issued_at,
        "scope" => scope,
        "expires_in" => expires_in,
        "token_type" => token_type,
        "client_id" => client_id,
        "access_token" => access_token
      }) do
    %Token{
      issued_at: issued_at,
      scope: scope,
      expires_in: expires_in,
      token_type: token_type,
      client_id: client_id,
      access_token: access_token
    }
  end
end
