defmodule Tipay.Factory do
  @moduledoc """
  Factory that creates models for testing
  """

  use ExMachina.Ecto, repo: Tipay.Repo
  use Tipay.EventFactory
  use Tipay.EventAttachmentFactory
  use Tipay.OfferFactory
  use Tipay.TransactionFactory
  use Tipay.UserTicketTokenFactory
  use Tipay.TicketFactory

  defp get_utc_date_with_days(days) do
    DateTime.utc_now()
    |> DateTime.add(days * 60 * 60 * 24)
  end

  def future_date_factory(days_in_future \\ 0) do
    get_utc_date_with_days(days_in_future)
  end

  def utc_yesterday_factory do
    DateTime.utc_now() |> DateTime.add(-60 * 60 * 24)
  end

  def utc_tomorrow_factory do
    DateTime.utc_now() |> DateTime.add(+60 * 60 * 24)
  end

  def utc_next_week_factory do
    DateTime.utc_now() |> DateTime.add(+60 * 60 * 24 * 7)
  end

  def vendor_factory do
    %Tipay.Vendors.Vendor{
      name: sequence(:vendor_name, &"vendor #{&1}"),
      description: sequence(:vendor_description, &"Description Ipsum #{&1}"),
      address: sequence(:vendor_address, &"ul. Najlepsza #{&1} 27-400, Ostrowiec Świętokrzyski"),
      opening_hours: "20:10-04:20",
      active: true
    }
  end

  def user_factory do
    %Tipay.Users.User{
      first_name: sequence(:user_first_name, &"John #{&1}"),
      last_name: sequence(:user_last_name, &"Wick #{&1}"),
      nick: sequence(:user_nick, &"jw #{&1}"),
      email: sequence(:user_email, &"email-#{&1}@example.com"),
      has_accepted_terms: true
    }
  end

  def vendor_user_factory do
    %Tipay.Vendors.VendorUser{
      vendor: build(:vendor),
      user: build(:user)
    }
  end

  def tpay_credentials_factory do
    %Tipay.Tpay.Credentials{
      api_key: "testApiKey",
      api_password: "testApiPassword",
      merchant_id: sequence(:tpay_credentials_merchant_id, &"123456#{&1}")
    }
  end

  def vendors_tpay_vendor_credentials_factory do
    %Tipay.VendorsTpay.VendorCredentials{
      vendor: build(:vendor),
      credentials: build(:tpay_credentials)
    }
  end

  def reset_password_token_factory do
    %Tipay.Users.ResetPasswordToken{
      user: build(:user),
      token: sequence(:reset_password_token, &"fake_token_#{&1}")
    }
  end
end
