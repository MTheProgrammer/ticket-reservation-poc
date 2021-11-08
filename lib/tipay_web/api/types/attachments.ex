defmodule TipayWeb.Api.Types.Attachments do
  @moduledoc """
  GraphQL Attachment types
  """
  use Absinthe.Schema.Notation

  enum :attachment_role do
    value(:main)
    value(:attachment)
  end

  object :attachment do
    field :id, non_null(:id)
    field :name, :string
    field :url, non_null(:string)
    field :role, non_null(:attachment_role)
  end
end
