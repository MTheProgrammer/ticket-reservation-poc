defmodule Tipay.EventAttachments.Main do
  @moduledoc """
  Uploader definition module for Event images.
  """

  use Waffle.Definition
  alias Tipay.Attachments.Identify
  alias Tipay.Attachments.Identify.FileInfo

  module_config = Application.get_env(:tipay, __MODULE__, [])
  sizes = Keyword.get(module_config, :image_sizes, [])
  permitted_formats = Keyword.get(module_config, :permitted_formats, [:jpeg, :png, :pdf])
  {min_width, min_height} = Keyword.get(module_config, :min_canvas_size, {400, 300})
  max_file_size = Keyword.get(module_config, :max_file_size, 5 * 1024 * 1024)

  versions =
    for {name, {w, h}} <- sizes, format <- [:jpg, :webp], is_integer(w) and is_integer(h) do
      {:"#{name}_#{format}", {format, name, {w, h}}}
    end
    |> Map.new()

  @version_map versions
  @versions Map.keys(@version_map) ++ [:original]
  @permitted_formats permitted_formats
  @min_height min_height
  @min_width min_width
  @max_file_size max_file_size

  def versions, do: @versions
  def version_config, do: @version_map

  def transform(:original, _), do: :noaction

  def transform(version, _) when version in @versions do
    {format, _, {w, h}} = @version_map[version]

    {:convert,
     fn input, output ->
       "#{input} -quality 85 -thumbnail #{w}x#{h}^ -gravity center -extent #{w}x#{h} -define webp:lossless=false #{
         format
       }:#{output}"
     end, format}
  end

  def file_changeset(file) do
    case Identify.identify_file(file) do
      {:ok, info} ->
        info
        |> FileInfo.validate_max_size(@max_file_size)
        |> FileInfo.validate_dimensions({@min_width, @min_height})
        |> FileInfo.validate_format(@permitted_formats)

      _ ->
        :error
    end
  end

  def validate({file, _}) do
    case file_changeset(file) do
      %FileInfo{valid?: true} ->
        true

      _ ->
        false
    end
  end

  def validate_with_json_error(file) do
    case file_changeset(file) do
      %FileInfo{valid?: true} ->
        :ok

      %FileInfo{} = info ->
        {:error, %{error: "FILE_VALIDATION_FAILED", message: Enum.join(info.errors, " ")}}

      _ ->
        {:error,
         %{error: "FILE_VALIDATION_FAILED", message: "Could not identify the uploaded file."}}
    end
  end

  def filename(:original, _), do: "original"

  def filename(version, _) when version in @versions do
    {_, name, _} = @version_map[version]
    name
  end

  def storage_dir(_, {_, event_id}) do
    "#{event_id}/photo"
  end
end
