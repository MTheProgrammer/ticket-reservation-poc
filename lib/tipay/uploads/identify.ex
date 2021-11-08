defmodule Tipay.Attachments.Identify do
  @moduledoc """
  This module contains functions used to identify file properties,
  such as size in bytes, image canvas size, or format.
  These functions can be then used to validate 
  """

  @format_string "%m %w %h %B"

  defmodule FileInfo do
    @moduledoc """
    Defines struct used to pass around attachment formatting data.
    """

    defstruct [:size, :format, :width, :height, :valid?, :errors]

    def parse(string) when is_binary(string) do
      [format, width, height, size] = String.split(string)

      format = format |> String.downcase() |> String.to_atom()

      %__MODULE__{
        format: format,
        width: String.to_integer(width),
        height: String.to_integer(height),
        size: String.to_integer(size),
        valid?: true,
        errors: []
      }
    end

    def add_error(%__MODULE__{errors: errors} = info, error) do
      errors = errors ++ [error]
      %{info | errors: errors, valid?: false}
    end

    def validate_max_size(%__MODULE__{} = info, limit) do
      if info.size > limit do
        add_error(info, "File size must be less than #{limit} bytes.")
      else
        info
      end
    end

    def validate_dimensions(%__MODULE__{} = info, {w, h}) do
      if info.width >= w and info.height >= h do
        info
      else
        add_error(info, "Image must be at least #{w}x#{h} pixels.")
      end
    end

    def validate_format(%__MODULE__{} = info, whitelist) do
      case info.format in whitelist do
        true ->
          info

        _ ->
          readable_list =
            Enum.map(whitelist, &to_string/1) |> Enum.map(&String.upcase/1) |> Enum.join(", ")

          add_error(info, "File format must be one of #{readable_list}.")
      end
    end
  end

  def get_executable_path do
    case System.find_executable("identify") do
      nil ->
        raise RuntimeError, "identify not found in PATH"

      other ->
        other
    end
  end

  defp call_identify_for(path) do
    identify = get_executable_path()
    System.cmd(identify, ["-format", @format_string, path], stderr_to_stdout: true)
  end

  def identify_file(path) when is_binary(path) do
    case call_identify_for(path) do
      {result, 0} ->
        {:ok, FileInfo.parse(result)}

      {error, _} ->
        {:error, error}
    end
  end

  def identify_file(%module{path: path}) when module in [Waffle.File, Plug.Upload] do
    identify_file(path)
  end
end
