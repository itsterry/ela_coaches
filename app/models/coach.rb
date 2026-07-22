class Coach < ApplicationRecord
  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[a-z]{2,}\z/i

  extend FriendlyId

  friendly_id :name, use: :slugged

  has_secure_password

  has_many :availabilities, dependent: :destroy
  has_many :sessions, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_FORMAT }
  validates :firstname, presence: true
  validates :lastname, presence: true

  def name
    [ firstname, lastname ].compact_blank.join(" ")
  end

  def should_generate_new_friendly_id?
    firstname_changed? || lastname_changed? || super
  end
end
