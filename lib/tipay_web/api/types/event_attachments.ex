defmodule TipayWeb.Api.Types.EventAttachments do
  @moduledoc """
  GraphQL Event Attachment types
  """
  use Absinthe.Schema.Notation

  object :event_attachment do
    field :id, non_null(:id)
    field :event, non_null(:event)
    field :event_id, non_null(:id)
    field :attachment, non_null(:attachment)
  end

  object :event_attachment_upload_result do
    field :success, non_null(:boolean)
    field :event_attachment, :event_attachment
    field :errors, :json
  end
end
