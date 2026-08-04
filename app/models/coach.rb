class Coach < ApplicationRecord
  include Emailable

  extend FriendlyId

  friendly_id :name, use: :slugged

  has_secure_password

  has_email :email

  has_many :availabilities, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :email, uniqueness: true
  validates :firstname, presence: true
  validates :lastname, presence: true

  def name
    [ firstname, lastname ].compact_blank.join(" ")
  end

  def should_generate_new_friendly_id?
    firstname_changed? || lastname_changed? || super
  end
end
