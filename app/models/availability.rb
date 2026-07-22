class Availability < ApplicationRecord
  STATUSES = %w[draft published].freeze

  belongs_to :coach

  has_many :slots, dependent: :destroy

  validates :date, presence: true
  validates :finish_time, presence: true
  validates :slot_length, numericality: { greater_than: 0 }
  validates :start_time, presence: true
  validates :status, inclusion: { in: STATUSES }

  validate :finish_time_after_start_time

  scope :published, -> { where(status: "published") }
  scope :upcoming, -> { where(date: Date.current..) }

  def free_times
    slot_times - taken_times
  end

  def full?
    free_times.empty?
  end

  def location
    zoom? ? "Zoom" : "Face to face"
  end

  def published?
    status == "published"
  end

  def slot_times
    return [] unless start_time && finish_time && slot_length.to_i.positive?

    Array.new(slot_count) { |index| start_time + (index * slot_length).minutes }
  end

  def taken?(time)
    taken_times.include?(time)
  end

  def taken_times
    slots.map(&:start_time)
  end

  private

  def finish_time_after_start_time
    return if start_time.blank? || finish_time.blank? || finish_time > start_time

    errors.add(:finish_time, "must be after the start time")
  end

  def slot_count
    ((finish_time - start_time) / slot_length.minutes).floor
  end
end
