defmodule TpayApi.Config do
  @tpay_base_url "https://api.tpay.com"
  def api_key do
    Application.get_env(:tipay, :api_key)
  end

  def api_password do
    Application.get_env(:tipay, :api_password)
  end

  def security_code do
    Application.get_env(:tipay, :security_code)
  end

  def get_endpoint do
    @tpay_base_url
  end
end
