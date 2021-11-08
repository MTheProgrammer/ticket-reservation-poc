defmodule TipayWeb.Api.EventAttachmentsQueryTest do
  @moduledoc """
  Event Attachments GraphQL test case
  """
  use TipayWeb.ApiCase, async: true

  describe "my event attachments query" do
    @published_events_with_attachments_query """
    {
      publishedEvents {
        attachments {
          id
          role
          url
          name
        }
      }
    }
    """

    test "returns list of Events with their Attachments" do
      event =
        build(:event)
        |> published()

      event_attachment = insert(:event_attachment, event: event)
      expected_url = event_attachment.file_name
      expected_name = event_attachment.display_name

      expected_role =
        event_attachment.role
        |> Atom.to_string()
        |> String.upcase()

      assert %{
               "publishedEvents" => [
                 %{
                   "attachments" => [
                     %{
                       "name" => ^expected_name,
                       "url" => ^expected_url,
                       "role" => ^expected_role
                     }
                   ]
                 }
               ]
             } = query(@published_events_with_attachments_query, %{})
    end
  end
end
