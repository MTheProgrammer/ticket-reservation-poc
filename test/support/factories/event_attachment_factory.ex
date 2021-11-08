defmodule Tipay.EventAttachmentFactory do
  @moduledoc """
  ExMachina Event Attachment factory
  """
  defmacro __using__(_opts) do
    quote do
      def event_attachment_factory do
        event = build(:event)

        %Tipay.EventAttachments.EventAttachment{
          event: event,
          role: :main,
          file_name: sequence(:event_attachment_file_name, &"attachment_#{&1}.png"),
          display_name: sequence(:event_attachment_display_name, &"Attachment #{&1}")
        }
      end
    end
  end
end
