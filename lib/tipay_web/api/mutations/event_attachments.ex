defmodule TipayWeb.Api.Mutations.EventAttachments do
  @moduledoc """
  Event Attachments GraphQL mutations
  """
  use Absinthe.Schema.Notation

  alias TipayWeb.Api.Resolvers.EventAttachmentsResolver

  object :event_attachments_mutations do
    @desc "Upload a file associated with an event"
    field :upload_event_attachment, non_null(:event_attachment_upload_result) do
      arg(:file, non_null(:upload))
      arg(:event_id, non_null(:id))
      arg(:role, non_null(:attachment_role))

      resolve(&EventAttachmentsResolver.upload_event_attachment/3)
    end
  end
end
