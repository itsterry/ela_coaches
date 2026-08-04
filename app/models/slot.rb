class Slot < ApplicationRecord
  include Emailable

  belongs_to :availability

  has_email :parent_email

  before_validation :assign_uuid, on: :create

  validates :parent_email, uniqueness: { scope: :availability_id, message: "has already booked a slot for this session" }
  validates :parent_name, presence: true
  validates :player_name, presence: true
  validates :start_time, presence: true, uniqueness: { scope: :availability_id }
  validates :uuid, presence: true, uniqueness: true

  validate :start_time_within_availability

  private

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def start_time_within_availability
    return if availability.blank? || start_time.blank?
    return if availability.slot_times.include?(start_time)

    errors.add(:start_time, "must be within the availability")
  end
end
