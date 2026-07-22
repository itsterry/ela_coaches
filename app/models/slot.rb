class Slot < ApplicationRecord
  belongs_to :availability

  validates :parent_name, presence: true
  validates :player_name, presence: true
  validates :start_time, presence: true, uniqueness: { scope: :availability_id }

  validate :start_time_within_availability

  private

  def start_time_within_availability
    return if availability.blank? || start_time.blank?
    return if availability.slot_times.include?(start_time)

    errors.add(:start_time, "must be within the availability")
  end
end
