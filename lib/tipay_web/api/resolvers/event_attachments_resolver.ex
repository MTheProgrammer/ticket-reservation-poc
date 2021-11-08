defmodule TipayWeb.Api.Resolvers.EventAttachmentsResolver do
  @moduledoc """
  Event Attachments GraphQL Resolver
  """
  alias Tipay.EventAttachments
  alias Tipay.EventAttachments.EventAttachment
  alias Tipay.Events
  alias Tipay.Events.Event
  alias Tipay.Users.User

  def upload_event_attachment(
        _,
        %{event_id: event_id} = attrs,
        %{context: %{current_user: %User{} = user}}
      ) do
    case check_permissions(user, event_id) do
      :ok -> create_event_attachment(attrs)
      error -> error
    end
  end

  defp check_permissions(%User{} = user, %Event{} = event) do
    Bodyguard.permit(Events, :edit_my_event, user, event)
  end

  defp check_permissions(%User{} = user, event_id) do
    case Events.get_event_by_id(event_id) do
      %Event{} = event -> check_permissions(user, event)
      error -> error
    end
  end

  defp create_event_attachment(attrs) do
    case EventAttachments.create_event_attachment(attrs) do
      {:ok, %EventAttachment{} = event_attachment} ->
        {:ok, %{success: true, event_attachment: event_attachment}}

      {:error, map} when is_map(map) ->
        {:ok, %{success: false, errors: map}}

      other ->
        other
    end
  end

  def event_attachments(%Event{id: event_id}, %{}, _) do
    event_attachments =
      EventAttachments.get_event_attachments(event_id)
      |> Enum.map(&event_attachment_to_attachment/1)

    {:ok, event_attachments}
  end

  defp event_attachment_to_attachment(%EventAttachment{
         id: id,
         display_name: display_name,
         file_name: file_name,
         role: role
       }) do
    %{id: id, url: file_name, name: display_name, role: role}
  end
end
