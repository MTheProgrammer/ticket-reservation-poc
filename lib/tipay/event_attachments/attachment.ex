defmodule Tipay.EventAttachments.Attachment do
  @moduledoc """
  Waffle uploader module for Event attachments of type
  `:attachment`.
  """

  use Waffle.Definition

  def storage_dir(_, {_, event_id}) do
    "#{event_id}/document"
  end

  def filename(version, {_, _}), do: version
end
