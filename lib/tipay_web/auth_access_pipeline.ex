defmodule TipayWeb.AuthAccessPipeline do
  @moduledoc """
  JWT authentication pipeline
  """
  @claims %{"typ" => "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :tipay,
    module: TipayWeb.Guardian

  plug Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
