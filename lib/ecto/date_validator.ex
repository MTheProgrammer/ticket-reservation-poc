defmodule Ecto.DateValidator do
  import Ecto.Changeset

  defguardp can_compare_dates(date_a, date_b) when not is_nil(date_a) and not is_nil(date_b)

  @doc """
  Validates whether given field date is not older than another date specified in options key :other
  boolean flag :original determines whether to use original field or the one from changeset
  """
  def validate_dates(changeset, field, options \\ []) do
    cmp = Keyword.get(options, :cmp, :gt)
    is_original = Keyword.get(options, :original, false)
    other_field = options[:other]
    other_field_str = Atom.to_string(other_field)

    validate_change(changeset, field, fn _, date ->
      other_date = get_other_date(changeset, other_field, is_original)

      case compare_dates(date, other_date) do
        ^cmp -> []
        :eq -> []
        _ -> [{field, options[:message] || date_cmp_message(cmp) <> " " <> other_field_str}]
      end
    end)
  end

  defp get_other_date(changeset, other_field, true), do: get_field(changeset, other_field)
  defp get_other_date(changeset, other_field, _), do: get_change(changeset, other_field)

  defp date_cmp_message(:gt), do: "must be later than"
  defp date_cmp_message(:lt), do: "must be earlier than"
  defp date_cmp_message(_), do: "invalid date compared to"

  defp compare_dates(date_a, date_b) when can_compare_dates(date_a, date_b) do
    DateTime.compare(date_a, date_b)
  end

  defp compare_dates(_, _), do: nil
end
