defmodule Tipay.EventAttachments do
  @moduledoc """
  Context module dealing with files attached to events.
  """

  import Ecto.Query, warn: false
  alias Tipay.Repo

  alias Tipay.EventAttachments.Attachment
  alias Tipay.EventAttachments.EventAttachment
  alias Tipay.EventAttachments.Main
  alias Tipay.Events

  import ShorterMaps

  def create_event_attachment(~M{event_id, file, role} = attrs)
      when role in [:main, :attachment] do
    case Events.get_event_by_id(event_id) do
      nil ->
        {:error, :not_found}

      event ->
        with {:ok, _} <- upload_event_attachment(role, event, file) do
          mapped_attrs = map_attrs(attrs, file)

          %EventAttachment{}
          |> EventAttachment.changeset(mapped_attrs)
          |> Repo.insert(
            on_conflict: :replace_all,
            conflict_target:
              {:unsafe_fragment, "(event_id) where (role = 'main'::event_attachment_role)"}
          )
        end
    end
  end

  defp map_attrs(%{} = attrs, %Plug.Upload{filename: file_name}) do
    Map.merge(attrs, %{file_name: file_name})
  end

  defp upload_event_attachment(:main, event, file) do
    with :ok <- Main.validate_with_json_error(file) do
      Main.store({file, event.id})
    end
  end

  defp upload_event_attachment(:attachment, event, file) do
    Attachment.store({file, event.id})
  end

  def get_event_attachments(event_id) do
    EventAttachment
    |> where(event_id: ^event_id)
    |> Repo.all()
  end
end
