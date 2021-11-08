defmodule Tipay.Users.Auth do
  @moduledoc """
  App Authorization service
  """
  alias Tipay.Repo
  alias Tipay.Users.User

  def login_with_email_pass(email, password) do
    Repo.get_by(User, email: email)
    |> Bcrypt.check_pass(password, hide_user: true)
  end
end
