module RecurrenceConcern
  extend ActiveSupport::Concern

  included do
    require "montrose"

    serialize :recurrence, Montrose::Recurrence
    serialize :start_time, Tod::TimeOfDay
    serialize :end_time, Tod::TimeOfDay

    before_save :clear_empty_recurrence

    validates :first_day, :start_time, :end_time, presence: true

    scope :exceptionnelles, -> { where(recurrence: nil) }
    scope :regulieres, -> { where.not(recurrence: nil) }
  end

  def starts_at
    start_time.on(first_day)
  end

  def ends_at
    if defined?(end_day) && end_day.present?
      end_time.on(end_day)
    else
      end_time.on(first_day)
    end
  end

  def exceptionnelle?
    recurrence.nil?
  end

  def occurences_for(inclusive_date_range)
    recurrence_until = recurrence&.to_hash&.[](:until)
    min_until = [inclusive_date_range.end, recurrence_until].compact.min.to_time.end_of_day

    if recurrence.present?
      recurrence.starting(starts_at).until(min_until).lazy.select { |o| o >= inclusive_date_range.begin.to_time }.to_a
    else
      inclusive_datetime_range = (inclusive_date_range.begin.to_time)..(inclusive_date_range.end.end_of_day)
      [starts_at].select { |t| inclusive_datetime_range.cover?(t) }
    end
  end

  def occurences_ranges_for(inclusive_date_range)
    occurences_for(inclusive_date_range).map do |occurence|
      occurence..(end_time.on(occurence.to_date))
    end
  end

  private

  def clear_empty_recurrence
    self.recurrence = nil if recurrence.present? && recurrence.to_hash == {}
  end
end
