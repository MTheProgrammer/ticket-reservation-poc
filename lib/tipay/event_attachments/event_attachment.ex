defmodule Tipay.EventAttachments.EventAttachment do
  @moduledoc """
  Event Attachment struct.
  Currently we have images and documents defined as events attachments.
  """
  use Tipay.Schema
  import Ecto.Changeset
  import EctoEnum

  @required ~w(role event_id file_name)a
  @cast @required ++ ~w(file_name display_name)a

  defenum(Role, :event_attachment_role, [:main, :attachment])

  schema "event_attachments" do
    field :role, Role, null: false
    belongs_to :event, Tipay.Events.Event
    field :file_name
    field :display_name
  end

  @doc false
  def changeset(event_attachments, attrs) do
    event_attachments
    |> cast(attrs, @cast)
    |> validate_required(@required)
    |> unique_constraint(:event_id, name: :event_attachments_main_image_unique_idx)
  end
end
