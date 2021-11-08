defmodule TipayWeb.Api.EventAttachmentsMutationTest do
  @moduledoc """
  EventAttachments GraphQL test case
  It is skipped until Absinthe.Plug uploader is fixed
  """
  use TipayWeb.ApiCase, async: true

  describe "Event Attachments upload" do
    @tag :skip

    @upload_event_document_mutation """
    mutation($eventId: ID!, $name: String!, $file: Upload!) {
      uploadEventDocument(eventId: $eventId, name: $name, file: $file) {
        success
        eventAttachment {
          event {
            id
          }
          attachment {
            id
          }
        }
        errors
      }
    }
    """

    test "uploads document for Event", %{conn: conn} do
      user = insert(:user)
      event = insert(:event, user: user)

      upload = %Plug.Upload{
        content_type: "text/plain",
        filename: "test.txt",
        path: Path.expand("../../../__files/test.txt", __DIR__)
      }

      assert %{
               "createEvent" => %{
                 "errors" => nil,
                 "success" => true,
                 "eventAttachment" => %{
                   "event" => %{
                     "id" => _
                   },
                   "attachment" => %{
                     "id" => _
                   }
                 }
               }
             } =
               query_over_router_file(
                 conn,
                 @upload_event_document_mutation,
                 %{eventId: event.id, file: "file", name: "super_file.csv"},
                 upload,
                 %{current_user: user}
               )
    end
  end
end
