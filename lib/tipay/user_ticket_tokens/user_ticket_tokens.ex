defmodule Tipay.UserTicketTokens do
  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.UserTicketTokens.UserTicketToken
  alias Tipay.Users.User

  def get_user_ticket_token!(id) when is_binary(id), do: Repo.get!(UserTicketToken, id)

  def get_user_ticket_token_by_id(id) when is_binary(id), do: Repo.get_by(UserTicketToken, id: id)

  def list_user_ticket_tokens(%User{id: user_id}) when is_binary(user_id) do
    UserTicketToken
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def create_user_token(attrs \\ %{}) do
    %UserTicketToken{}
    |> UserTicketToken.changeset(attrs)
    |> Repo.insert()
  end
end
