defmodule Tipay.EventFactory do
  @moduledoc """
  ExMachina Event factory
  """
  defmacro __using__(_opts) do
    quote do
      def event_factory do
        days_sequence = sequence(:event_days, [1, 2, 3]) - 5

        published_at = get_utc_date_with_days(days_sequence)
        begins_at = get_utc_date_with_days(days_sequence + 2)
        ends_at = get_utc_date_with_days(days_sequence + 3)

        user = build(:user)
        vendor = build(:vendor)

        %Tipay.Events.Event{
          name: sequence(:event_name, &"Event #{&1}"),
          short_description:
            sequence(
              :event_short_description,
              &"Lorem Ipsum Short #{&1}"
            ),
          description:
            sequence(
              :event_short_description,
              &"Lorem Ipsum Long #{&1}"
            ),
          published_at: published_at,
          begins_at: begins_at,
          ends_at: ends_at,
          active: true,
          vendor: vendor,
          user: user
        }
      end

      def published(%Tipay.Events.Event{} = event) do
        %{event | published_at: build(:utc_yesterday)}
      end

      def unpublished(%Tipay.Events.Event{} = event) do
        %{event | published_at: build(:utc_next_week)}
      end

      def active(%Tipay.Events.Event{} = event) do
        %{event | active: true}
      end

      def inactive(%Tipay.Events.Event{} = event) do
        %{event | active: false}
      end

      def future(%Tipay.Events.Event{} = event) do
        %{
          event
          | published_at: build(:utc_next_week),
            begins_at: build(:utc_next_week),
            ends_at: build(:utc_next_week)
        }
      end

      def pending(%Tipay.Events.Event{} = event) do
        %{event | ends_at: build(:utc_next_week)}
      end

      def past(%Tipay.Events.Event{} = event) do
        %{
          event
          | published_at: build(:utc_yesterday),
            begins_at: build(:utc_yesterday),
            ends_at: build(:utc_yesterday)
        }
      end
    end
  end
end
